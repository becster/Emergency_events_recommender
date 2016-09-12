#Exponential weightened Moving Average EWMA
#Moving Average analysis
library(forecast)
library("TTR")


gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_cluster_unique.csv",head=TRUE,sep=",")
gt_data$date <-as.Date( as.character(gt_data$date),"%Y-%m-%d")
#Subsetting data
sub_gt <- subset(gt_data,gt_data$date < as.Date('2015-05-31'))
sub_gt$cluster <- factor(sub_gt$cluster)
n_end = nrow(sub_gt)
n_end
head(sub_gt)

#Creating the Time series object
ts_gt <- ts(sub_gt$cluster,start = c(2012,10),end = c(2015,8),frequency = 300 )
ts_gt

ewma <- EMA(ts_gt,n=3,wilder = TRUE)
fcast <- forecast(ewma,h=50)
accuracy(fcast,gt_data$cluster[n_end:(n_end+50)])
plot(fcast,ylim=c(0,15),main="EWMA, order=10")


