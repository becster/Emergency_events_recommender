#Singular input for LSTM

gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_cluster_unique.csv",head=TRUE,sep=",")
gt_data$date <-as.Date( as.character(gt_data$date),"%Y-%m-%d")

#Subsetting data
sub_gt <- subset(gt_data,gt_data$date < as.Date('2015-08-31'))
#sub_gt$cluster <- factor(sub_gt$cluster)
table(sub_gt$cluster)
nrow(sub_gt)
head(sub_gt)
input_singular <- matrix(ncol = 15,nrow = (nrow(sub_gt)),data=0) 
for (i in 1:nrow(sub_gt)) {
  input_singular[i,sub_gt$cluster[i]] = 1
}

write.table(input_singular, file = "C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\net_input_singular.csv", sep = ",", col.names = NA,qmethod = "double")
