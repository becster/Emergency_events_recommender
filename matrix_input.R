#Construction of Matrix for ANN
gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_cluster_unique.csv",head=TRUE,sep=",")
gt_data$date <-as.Date( as.character(gt_data$date),"%Y-%m-%d")
#Subsetting data
sub_gt <- subset(gt_data,gt_data$date < as.Date('2015-05-31'))
sub_gt$cluster <- factor(sub_gt$cluster)


input <- matrix(ncol = 14,nrow = 1)
