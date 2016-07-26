#General data-analysis

gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_month_year.csv",head=TRUE,sep=",")

plot(x=gt_data$a_month,y=gt_data$quantity)
lag.plot(gt_data,lags = 10, do.lines = FALSE)


data("LakeHuron")


acf(gt_data)
LH.yw <- ar(x=LakeHuron,order.max = 1, method = "mle" )
LH.yw$ar

#Convert to time series
TS_GT <- ts(gt_data$quantity,start = c(2012,10),end = c(2015,8),frequency = 12)

LH.mle <- ar(x=TS_GT,order.max = 1, method = "mle" )
LH.mle$ar
LH.mle$x.mean
LH.mle$var.pred

#ARIMA
library(forecast)
LH.arima <- auto.arima(TS_GT)
fcast <- forecast(LH.arima)
plot(fcast)

accuracy(fcast)
