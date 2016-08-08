library(forecast)

gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_cluster_unique.csv",head=TRUE,sep=",")
gt_data$date <-as.Date( as.character(gt_data$date),"%Y-%m-%d")

#Subsetting data
sub_gt <- subset(gt_data,gt_data$date < as.Date('2015-05-31'))
#sub_gt$cluster <- factor(sub_gt$cluster)
table(sub_gt$cluster)
nrow(sub_gt)
head(sub_gt)

#Creating the Time series object
ts_gt <- ts(sub_gt$cluster,start = 1,end = 8684,frequency = 1)
plot(ts_gt)

#ARIMA
LH.arima <- auto.arima(ts_gt)
fcast <- forecast(LH.arima)
plot(fcast,col = "red")
accuracy(fcast,)
