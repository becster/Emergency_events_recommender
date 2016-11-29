import numpy as np
import random

#Number of batchs
num_unrollings= 1#6#len(input_data)
#7 nodes because the vector will evaluate the 7 past days.
num_nodes = 15
#15 different areas
area_size = 15
batch_size = 7
#valida size of a prediction
valid_size= 1

#print(train_size, train_text[:7])
#print(valid_size, valid_text[:7])

#Utilies----------------------------------------------------------------
def logprob(predictions,labels):
    #Log-probability of the true labels in a predicted batch
    predictions[predictions < 1e-10] = 1e-10
    return np.sum(np.multiply(labels,-np.log(predictions))) / labels.shape[0]

def sample_distribution(distribution):
    #Sample one element from a distribution
    r = random.uniform(0,1)
    s = 0
    for i in range(len(distribution)):
        s += distribution[i]
        if s >= r:
            return  i
    return len(distribution) - 1

def sample(prediction):
    #Turn a (column) prediction into 1-hot encoded samples.
    p = np.zeros(shape=[1, area_size], dtype=np.float)
    p[0, sample_distribution(prediction[0])] = 1.0
    return p

def cluster(probabilities):
    return  [c for c in np.argmax(probabilities,1)]

def u_cluster(probabilities):
    return np.argmax(probabilities)

def random_distribution():
    #Generate a random column of probabilities.
    b = np.random.uniform(0.0, 1.0, size=[1, area_size])
    return b/np.sum(b, 1)[:,None]
