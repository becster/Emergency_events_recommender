#Construction of Matrix for RNN-ARIMA

gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\group_cluster_quantity.csv",head=TRUE,sep=",")
gt_data$date <-as.Date( as.character(gt_data$date),"%m/%d/%Y")

#Subsetting data: Add 7 row at top, 7 row at the bottom to handle the summation.
gt_data <- subset(gt_data,gt_data$date < as.Date('2015-10-31'))
nrow_gt = nrow(gt_data)
input <- matrix(ncol = 15,nrow = (nrow_gt+14),data=0) 
#Group by, Column=Cluster, row = Day, Value = Quantity
for (i in 1:nrow(input)) {
    cell<-as.vector(unlist(strsplit(as.character(gt_data$output[i]),"[@]")))
    for (j in 1:length(cell)) {
      cell_cluster <- unlist(strsplit(cell[j],"[:]"))
      #Order of the cell columns: [1]Cluster : [2]Quantity
      #Summation in the same cell it's allowed given that more than 1 EV could be in te same place.
      a <- as.numeric(cell_cluster[1])
      b <- as.numeric(cell_cluster[2])
      
      if((i-1)<=nrow_gt){
        input[i+6,a]= b + input[i+6,a]
        print(i)
      }
    }  
}



ts_input <- matrix(ncol=1,nrow = nrow(gt_data),data=0)
#Mean average
for(i in 8:nrow(input)){
  x<- ((input[i-1,]+input[i-2,]+input[i-3,]+input[i-4,]+input[i-5,]+input[i-6,]+input[i-7,])/7)  
  ts_input[i] <- which(x==max(x))
}



ts_gt <- ts(input,start = 1,end = 1009,frequency = 1)
plot(ts_gt)
#ARIMA
LH.arima <- auto.arima(ts_gt)
fcast <- forecast(LH.arima)
plot(fcast,col = "red")
accuracy(fcast,)
