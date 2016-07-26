gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\GT.csv",head=TRUE,sep=",")
gt_data$date2 <- as.Date(as.character(gt_data$date),"%m/%d/%Y")

head(gt_data)


library("caret")
inTrain = createDataPartition(y=gt_data$id_boleta, p = 0.8,list = FALSE)

trainingGT <- gt_data[inTrain,]
testingGT <- gt_data[-inTrain,]

for (dt in trainingGT$date) {
  trainingGT<- subset(trainingGT,date == dt)$Cluster
}


#month_gt <- subset(trainingB,date2 >= as.Date("2013-01-01") & date2 <= as.Date("2016-12-31") & Cluster == 12)
#plot(x=month_gt$date2,y=month_gt$quantity,lwd=2,col="blue")
#grid(lty=4)
#lines(month_gt$date,col="red")
#points_ts <- ts(month_gt$quantity,frequency = 365)
#points_ts
#plot.ts(points_ts)






