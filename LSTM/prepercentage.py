import tensorflow as tf
import utilities as u
import input_preprocessing as i_pre
import matplotlib.pyplot as plt




# Graph creation ----------------------------------------------------------
graph = tf.Graph()
with graph.as_default():
    keep_prob = tf.placeholder(tf.float32)

    #Input gate: input, previous output, and bias.
    ix = tf.Variable(tf.truncated_normal([u.area_size,u.num_nodes],-0.1,0.1))
    im = tf.Variable(tf.truncated_normal([u.num_nodes,u.num_nodes],-0.1,0.1))
    ib = tf.Variable(tf.zeros([1,u.num_nodes]))

    #Forget gate: input, previous output, and bias.
    fx = tf.Variable(tf.truncated_normal([u.area_size, u.num_nodes], -0.1, 0.1))
    fm = tf.Variable(tf.truncated_normal([u.num_nodes, u.num_nodes], -0.1, 0.1))
    fb = tf.Variable(tf.zeros([1, u.num_nodes]))

    #Memory cell: input, state and bias
    cx = tf.Variable(tf.truncated_normal([u.area_size, u.num_nodes], -0.1, 0.1))
    cm = tf.Variable(tf.truncated_normal([u.num_nodes, u.num_nodes], -0.1, 0.1))
    cb = tf.Variable(tf.zeros([1, u.num_nodes]))

    #Output gate: input, previous output, and bias
    ox = tf.Variable(tf.truncated_normal([u.area_size, u.num_nodes], -0.1, 0.1))
    om = tf.Variable(tf.truncated_normal([u.num_nodes, u.num_nodes], -0.1, 0.1))
    ob = tf.Variable(tf.zeros([1, u.num_nodes]))

    # Variables saving state across unrollings
    saved_output = tf.Variable(tf.zeros([u.batch_size, u.num_nodes]), trainable=False,name="Saved_Output")
    saved_state  = tf.Variable(tf.zeros([u.batch_size, u.num_nodes]), trainable=False,name="Saved_State")

    #Classifier weights and biases
    w = tf.Variable(tf.truncated_normal([u.num_nodes,u.area_size],-0.1,0.1),name="Weights")
    b = tf.Variable(tf.zeros([u.area_size]),name="Biases")

    #Cell definition for computation.
    def lstm_cell(i,o,state):
        input_gate = tf.sigmoid(tf.matmul(i, ix) + tf.matmul(o, im) + ib,name = "Input_Gate")
        forget_gate = tf.sigmoid(tf.matmul(i, fx) + tf.matmul(o, fm) + fb,name = "Forget_Gate")
        update = tf.matmul(i, cx) + tf.matmul(o, cm) + cb
        state = forget_gate * state + input_gate * tf.tanh(update)
        output_gate = tf.sigmoid(tf.matmul(i, ox) + tf.matmul(o, om) + ob,name = "Output_Gate")
        return output_gate * tf.tanh(state), state

    # Input data.
    # Place holder: Create a variable that is assigned later
    train_data = list()
    for _ in range(u.num_unrollings + 1):
        train_data.append(tf.placeholder(tf.float32, shape=[u.batch_size, u.area_size],name="Train_Data_List"))
    train_inputs = train_data[:u.num_unrollings]
    train_labels = train_data[1:]  # labels are inputs shifted by one time step.

    # Unrolled LSTM loop.
    outputs = list()
    output = saved_output
    state = saved_state
    for i in train_inputs:
        output, state = lstm_cell(i, output, state)
        outputs.append(output)

#Control_dependencies especifies the order of operations to be done.
    with tf.control_dependencies([saved_output.assign(output), saved_state.assign(state)]):

        #Cross entropy with logits computes softwam cross entropy
        #Computes softmax cross entropy between logits and labels.
        #Measures the probability error in discrete classification tasks in which the classes are mutually exclusive (each entry is in exactly one class).
        logits = tf.nn.xw_plus_b(tf.concat(0, outputs), w, b)
        loss = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits, tf.concat(0, train_labels)))

        # Accuracy
        correct_prediction = tf.equal(logits, tf.concat(0, train_labels))
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

    # Optimizer.
    global_step = tf.Variable(0)
    learning_rate = tf.train.exponential_decay(1.0, global_step, 100, 0.9, staircase=False)
    optimizer = tf.train.GradientDescentOptimizer(learning_rate)
    gradients, v = zip(*optimizer.compute_gradients(loss))
    gradients, _ = tf.clip_by_global_norm(gradients, 1.25)
    optimizer = optimizer.apply_gradients(
    zip(gradients, v), global_step=global_step)

    # Predictions.
    train_prediction = tf.nn.softmax(logits)


    # Sampling and validation eval: batch 1, no unrolling.
    sample_input = tf.placeholder(tf.float32, shape=[u.batch_size, u.area_size],name="Sample_Input")
    saved_sample_output = tf.Variable(tf.zeros([u.batch_size, u.num_nodes]),name = "Saved_Sample_Output")
    saved_sample_state = tf.Variable(tf.zeros([u.batch_size, u.num_nodes]),name = "Saved_Sample_State")
    reset_sample_state = tf.group(  saved_sample_output.assign(tf.zeros([u.batch_size, u.num_nodes])), saved_sample_state.assign(tf.zeros([u.batch_size, u.num_nodes])),name = "Reset_IOS")
    sample_output, sample_state = lstm_cell( sample_input, saved_sample_output, saved_sample_state)



    with tf.control_dependencies([saved_sample_output.assign(sample_output),saved_sample_state.assign(sample_state)]):
        sample_prediction = tf.nn.softmax(tf.nn.xw_plus_b(sample_output, w, b))

num_steps = 1037
summary_frequency = 10
errors = []


with tf.Session(graph=graph) as session:
  tf.initialize_all_variables().run()

  print('Initialized')
  writer = tf.train.SummaryWriter("/tmp/basic", session.graph_def)
  for step in range(num_steps):
    batches = i_pre.train_batches.next()
    mean_loss = 0
    #Dictionary
    feed_dict = dict()
    for i in range(u.num_unrollings + 1):
      feed_dict[train_data[i]] = batches[i]

    _, l, predictions, lr = session.run(
      [optimizer, loss, train_prediction, learning_rate], feed_dict=feed_dict)
    mean_loss += l

    '''Matrix 15 x 7'''
    #print(predictions)
    errors.append(mean_loss)

    if step % summary_frequency == 0:
      if step > 0:
        mean_loss = mean_loss / summary_frequency
        print('Average loss at step %d: %f learning rate: %f' % (step, mean_loss, lr))
      if step > 950:
          for _ in range(u.valid_size):
              b = i_pre.valid_batches.next()
              #feed_dict[train_data[i]] = b[1]
              predictions = sample_prediction.eval({sample_input: b[0]})
              #feed_dict[outputs[0]] = predictions
              #valid_logprob = valid_logprob + logprob(predictions[6], b[1][6])
              y_ = u.u_cluster(predictions)
              y = u.u_cluster(b[1])
              #train_accuracy = accuracy.eval(feed_dict={y, y_})
              #y = b[1]
              #y_ = predictions
              #print(accuracy.eval(feed_dict={logits: train_data[i], train_labels: predictions}))
              print('Y = %d vrs Y_ = %d'% (y,y_))

precision = dict()
recall = dict()
average_precision = dict()



writer = tf.train.SummaryWriter("/tmp/basic", session.graph_def)

'''
import matplotlib.pyplot as plt
plt.plot([np.mean(errors[i-7:i]) for i in range(len(errors))])
plt.show()
#plt.savefig("errors.png")
'''


#writer = csv.writer(open("/root/PycharmProjects/Tutorials/GuatemalaData/net_output_percentage_281216.csv", 'w'))
for i in range(len(errors)):
    writer.writerow([errors[i]])

