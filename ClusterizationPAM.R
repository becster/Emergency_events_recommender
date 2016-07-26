gt_data = read.csv("~\\mercatorCoordinates.csv",head=TRUE,sep=",")
head(gt_data)
summary(gt_data)
names(gt_data) <- c('northing','easting','clustering')

library(cluster)
library(flexclust)
library("caret")
inTrain = createDataPartition(y=gt_data$id_boleta, p = 0.8,list = FALSE)

trainingGT <- gt_data[inTrain,]
testingGT <- gt_data[-inTrain,]

s <- stepFlexclust(gt_data, k=2:20, nrep=20)
plot(s)


#classifying the entries in 34 different clusters.
y.pam <- pam(gt_data, 20, stand=TRUE)
gt_data$cluster <- y.pam$cluster
names(gt_data) <- c('northing','easting','cluster')

write.table(gt_data, file = "C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\mercatorCoordinatesClassified.csv", sep = ",", col.names = NA,
            qmethod = "double")

plot(gt_data$easting,gt_data$northing, col=gt_data$cluster, main="Emergency events 20 classes", cex=.5, pch=16, xlab="Easting", ylab="Northing")
# add the medoids, they are in the same order as the clustering vector
points(y.pam$medoids, pch=15, col=1:5, cex=1.25)

for(i in 1:20)
{
  segments(x0=y.pam$medoids[i,][1], y0=y.pam$medoids[i,][2], x1=gt_data$easting[gt_data$cluster == i], y1=gt_data$northing[gt_data$cluster ==i], col=i, lty=3)
}

a = matrix(ncol= 7)

for(i in 0:nrow(gt_data))
{
  a[i:7] <- gt_data$cluster[i:i+6]
}
  
