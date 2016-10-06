library(forecast)

gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_cluster_unique.csv",head=TRUE,sep=",")
gt_data$date <-as.Date( as.character(gt_data$date),"%Y-%m-%d")
#Subsetting data
sub_gt <- subset(gt_data,gt_data$date < as.Date('2015-05-31'))
#sub_gt$cluster <- factor(sub_gt$cluster)
n_end = nrow(sub_gt)
n_end
head(sub_gt)


#ARIMA
ts_ar <- NULL
ts_ar <- ts(sub_gt$cluster,start = c(2012,10), end= c(2015,5) ,frequency = 300 )
plot(ts_ar)

LH.arima <- auto.arima(ts_ar)

fcast1 <- forecast.Arima(LH.arima,h = 50)
fcast$model

plot(fcast1$fitted,main="ARIMA(2,0,1)")
plot(fcast1$residuals,main="ARIMA(2,0,1)")
plot.Arima(LH.arima,main="ARIMA(2,0,1)",ylim=c(0,15),h=20)

accuracy(fcast1,gt_data$cluster[n_end:(n_end+50)])



