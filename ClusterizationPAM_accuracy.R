gt_data = read.csv("C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_cluster_unique.csv",head=TRUE,sep=",")
head(gt_data)
summary(gt_data)
names(gt_data)

library(cluster)
library(flexclust)
library("caret")

#inTrain = createDataPartition(y=gt_data$id_boleta, p = 0.8,list = FALSE)
#trainingGT <- gt_data[inTrain,]
#testingGT <- gt_data[-inTrain,]

#------------PAM Cluster-----------------------------------------
#classifying the entries in different clusters.

# figure out a good number of clusters use a range of 2 to 10 clusters, with 20 reps each
s <- stepFlexclust(gt_data[2:3], k=2:100, nrep=10,FUN=kcca,multicore = TRUE)
s
plot(s)

y.pam <- pam(gt_data[4:5], 15, stand=TRUE)
gt_data$cluster <- y.pam$cluster
y.pam$clusinfo
head(gt_data[5:6])
plot(gt_data[6:5],col=y.pam$cluster+1L,pch = y.pam$cluster, xlab="Latitude",ylab="Longitude",main="PAM 15 Classes")

write.table(gt_data, file = "C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\ev_cluster_unique.csv", sep = ",", col.names = NA,
            qmethod = "double")

#------------DBSCAN (Density-based spatial clustering of application with noise)
library("dbscan")
class(gt_data)
x <- as.matrix(gt_data[5:6])
db <- dbscan(x, eps=1000 , minPts = 120,search = "linear")  
db
gt_data$dbscan <- db$cluster

pairs(x, col = db$cluster + 1L,pch=)4
  





#-----------K-means 4-----------------------------------------
km <- kmeans(gt_data[5:6],15,iter.max = 10, nstart = 40)
km$cluster
plot(x,pch=9)
points(km$centers,col = 2 + 1L,pch=6)
gt_data$kmeans <- km$cluster
head(gt_data)



write.table(gt_data, file = "C:\\Users\\isys05\\Desktop\\Research\\TAIWAN_2016\\Data\\cluster_eval.csv", sep = ",", col.names = NA,
            qmethod = "double")

#-----------SOM-----------------------------------------------
library("kohonen")
head(gt_data)

x = gt_data[4:6]
x_som = as.matrix(x)
som_grid <- somgrid(xdim=10,ydim=10,topo="hexagonal")
som_model <- som(x_som, 
                 grid=som_grid, 
                 rlen=100, 
                 alpha=c(0.05,0.01),
                 radius = 50000,
                 keep.data = TRUE,
                 n.hood="circular" )

plot(som_model)
plot(som_model, type="changes")
plot(som_model, type="count")
plot(som_model, type="dist.neighbours")
plot(som_model, type="codes")
plot(som_model, type = "property", property = som_model$codes[,4], main=names(som_model$data)[4], palette.name=coolBlueHotRed)
plot(som_model$data, pch = 3, col = "green")

points(som_model$codes,pch=som_model$radius)

mydata <- som_model$codes 
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var)) 
for (i in 2:15) {
  wss[i] <- sum(kmeans(mydata, centers=i)$withinss)
}
plot(wss)


som_cluster <- cutree(hclust(dist(som_model$codes)),k=15 )
# plot these results:
plot(som_model, type="mapping", bgcol = som_cluster, main = "Clusters") 
add.cluster.boundaries(som_model, som_cluster)


library(clusterCrit)

#Evualte best algorithm
#PAM
PAM = matrix()
PAM[0] <- intCriteria(as.matrix(gt_data[5:6]),gt_data$cluster,"Davies_Bouldin")
PAM[1] <- intCriteria(as.matrix(gt_data[5:6]),gt_data$cluster,"Dunn")
PAM[2] <- intCriteria(as.matrix(gt_data[5:6]),gt_data$cluster,"Silhouette")

#KMEANS
indx <- intCriteria(as.matrix(gt_data[5:6]),gt_data$kmeans,"Davies_Bouldin")
indx <- intCriteria(as.matrix(gt_data[5:6]),gt_data$kmeans,"Dunn")
indx <- intCriteria(as.matrix(gt_data[5:6]),gt_data$kmeans,"Silhouette")

#DBSCAN
indx <- intCriteria(as.matrix(gt_data[5:6]),gt_data$dbscan,"Davies_Bouldin")
indx <- intCriteria(as.matrix(gt_data[5:6]),gt_data$dbscan,"Dunn")
indx <- intCriteria(as.matrix(gt_data[5:6]),gt_data$dbscan,"Silhouette")