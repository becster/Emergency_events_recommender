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

plot(gt_data[4:5],col=y.pam$cluster+1L,pch = y.pam$cluster)


#------------DBSCAN (Density-based spatial clustering of application with noise)
library("dbscan")
class(gt_data)
x <- as.matrix(gt_data[4:5])
db <- dbscan(x, eps=1000 , minPts = 5,search = "kdtree")  
db
pairs(x, col = db$cluster + 1L,pch=4)
  




#-----------K-means 4-----------------------------------------
km <- kmeans(gt_data[4:5],15,iter.max = 10, nstart = 40)
km$centers
plot(x,pch=9)
points(km$centers,col = 2 + 1L,pch=6)



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




#Evualte best algorithm
#PAM
db_score = 0;
n = nrow(y.pam$clusinfo)
for(i in 1:(n-1))
{
  separation = y.pam$clusinfo[i,4]
  av_distance = y.pam$clusinfo[i,3]+y.pam$clusinfo[i+1,4]
  db_score = db_score + (av_distance/separation)  
  
}
db_score = (1/n)*db_score
db_score
#--------------10 classes
#1.667317 
#--------------20 classes
#1.821151

#K-Means
db_score = 0;
n = nrow(km$size)
for(i in 1:(n-1))
{
  separation = km$
  av_distance = y.pam$clusinfo[i,3]+y.pam$clusinfo[i+1,4]
  db_score = db_score + (av_distance/separation)  
  
}
db_score = (1/n)*db_score
db_score