#Exponential weightened Moving Average EWMA
#Moving Average analysis
library(forecast)
library("TTR")


gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_cluster_unique.csv",head=TRUE,sep=",")
gt_data$date <-as.Date( as.character(gt_data$date),"%Y-%m-%d")
#Subsetting data
sub_gt <- subset(gt_data,gt_data$date < as.Date('2015-05-31') & gt_data$date > as.Date('2012-12-01'))
#sub_gt$cluster <- factor(sub_gt$cluster)
table(sub_gt$cluster)
end_ts = nrow(sub_gt)

#Creating the Time series object
ts_gt <- ts(sub_gt$cluster,start = 1,end = end_ts,frequency = 1 )

plot(ts_gt, xlab = "Emergency Event", ylab = "Cluster", main ="Moving Average, order=7")
ewma <- EMA(ts_gt,n=10)
fcast <- forecast(ewma,robust = TRUE,h=1000,level=c(80,95))
lines(m_v,col = "red")
accuracy(fcast,gt_data$cluster[628:637])
plot(fcast)

