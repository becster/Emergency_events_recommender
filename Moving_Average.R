#Moving Average analysis
library(forecast)


gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_cluster_unique.csv",head=TRUE,sep=",")
gt_data$date <-as.Date( as.character(gt_data$date),"%Y-%m-%d")
#Subsetting data
sub_gt <- subset(gt_data,gt_data$date < as.Date('2015-05-31'))
sub_gt$cluster <- factor(sub_gt$cluster)
n_end = nrow(sub_gt)
head(sub_gt)

#Creating the Time series object
ts_gt <- ts(sub_gt$cluster,start = 1,end = n_end,frequency = 1)

plot(ts_gt, xlab = "Emergency Event", ylab = "Cluster", main ="Moving Average, order=10")
m_v <- ma(ts_gt,order=10)
lines(m_v,col="red")
fc <- forecast(m_v,robust = TRUE,h=100,)
accuracy(fc,gt_data$cluster[8675:8775])
plot(fc)



# Create the function.
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

getmode(ts_gt)
