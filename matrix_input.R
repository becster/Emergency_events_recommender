##                            Construction of Matrix for RNN-ARIMA              ##
## EV = Emergency Event
library(forecast)
library("TTR")

gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\group_cluster_quantity.csv",head=TRUE,sep=",")
gt_data$date <-as.Date( as.character(gt_data$date),"%m/%d/%Y")

#Group representation -> Column=Cluster, r
#row = Day, Value = Quantity
#Subsetting data: Add 7 row at top, 7 row at the bottom to handle the summation.
gt_data <- subset(gt_data,gt_data$date < as.Date('2015-10-31'))
nrow_gt = nrow(gt_data)
input <- matrix(ncol = 15,nrow = (nrow_gt+14),data=0) 
input_singular <- matrix(ncol = 15,nrow = (nrow_gt+14),data=0) 
for (i in 1:nrow(input)) {
    cell<-as.vector(unlist(strsplit(as.character(gt_data$output[i]),"[@]")))
    for (j in 1:length(cell)) {
      #Sintax of columns: [1]Cluster : [2]Quantity
      #Summation in the same cell it's allowed given that more than 1 EV could be in te same place.
      cell_cluster <- unlist(strsplit(cell[j],"[:]"))
      a <- as.numeric(cell_cluster[1])
      b <- as.numeric(cell_cluster[2])
      
      #Avoids out of bound index problems
      if((i-1)<=nrow_gt){
        input[i+6,a]= b + input[i+6,a]
        print(i)
      }
    }  
}


#Vector to create a time series object
ts_input <- matrix(ncol=1,nrow = nrow(gt_data),data=0)
av_input <- matrix(ncol = 15,nrow = (nrow_gt+14),data=0) 

#Average per 7 days before each EV
for(i in 8:nrow(input)){

  x<- ((input[i-1,]+input[i-2,]+input[i-3,]+input[i-4,]+input[i-5,]+input[i-6,]+input[i-7,])) 
  av_input[i,] <- x
  x <- x/7
  n=0
  n<-ncol(subset(x,x>0))
  x<-(pbinom(x,15,n,log=TRUE))
  av_input[i,] <- x
  ts_input[i] <- which(x==max(x))
}
write.table(av_input, file = "C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\net_input_dist.csv", sep = ",", col.names = NA,qmethod = "double")

#Creation of time series Object
ts_gt <- ts(ts_input[1:1000],start = 1,end = 1000,frequency = 1)

#ARIMA
LH.arima <- auto.arima(ts_gt)
fcast <- forecast(LH.arima)
plot(fcast)
accuracy(fcast,ts_gt[1000:1030])


#Exponential weightened Moving Average EWMA
ewma <- EMA(ts_input[1:1000],n=7)
plot(ewma)
fcast <- forecast(ewma,robust = TRUE,h=100,level=c(80,95))
accuracy(fcast,ts_gt[1000:1030])
plot(fcast)


#Moving Average
m_v <- ma(ts_input[1:1000],order=7)
plot(m_v)
fcast <- forecast(m_v,robust = TRUE,h=100,level=c(80,95))
accuracy(fcast,ts_gt[1000:1030])
plot(fcast)

