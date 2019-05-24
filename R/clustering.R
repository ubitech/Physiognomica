clustering <- function(prometheus_url,periods,step,metrics,enriched) {
  step <- paste("&step=" ,step, sep="")
  print("clustering")

  
  if (isTRUE(enriched)){
    print("i am enriched")
    metrics_list =data.frame(name=metrics,friendlyName=metrics,dimensions = stringr::str_extract(metrics, stringr::regex("\\{.*\\}")))
  }
  else{
    #enrichMaestroPrometheusMetricsWithDimensionsWithoutSession
    metrics_list <- Physiognomica::enrichMaestroPrometheusMetricsWithDimensionsWithoutSession(prometheus_url,metrics)
  }
  
  datalist = list()
  for(i in 1:nrow(periods)) {
    #print(periods[i, "start"])
    start <- paste("&start=" ,periods[i, "start"], sep="")
    end <- paste("&end=" ,periods[i, "end"], sep="")
    #print(start)
    #print(end)
    
    finaldata <- data.frame()
    for(i in 1:nrow(metrics_list)) {
      row <- metrics_list[i,]
      metric_name <-row$name
      metric_friendlyName <-row$friendlyName
      
      dimensions <-row$dimensions
      print("dimensions")
      print(dimensions)
      mydata <- Physiognomica::convertPrometheusDataToTabularFormat(prometheus_url,metric_name,metric_friendlyName,dimensions,start,end,step)
      if (nrow(finaldata)==0){ finaldata <- mydata
      }else{ 
        if (nrow(mydata)!=0){
          finaldata <- merge(x=finaldata,y=mydata, by.x = "timestamp")
        }
      }
    }
    print("get final data")
    colnames(finaldata)
    datalist[[i]] <-finaldata
    
  }
  
  big_data = do.call(rbind, datalist)
  
  big_data[] <- lapply(big_data, function(x) {
    if(is.factor(x)) as.numeric(as.character(x)) else x
  })
  sapply(big_data, class)
  #big_data <- subset( big_data, select = -c(timestamp) )
  big_data$timestamp <-0
  
  #print(big_data)
  big_data <- Filter(function(x) sd(x) != 0, big_data)
  
  if(length(big_data)==0){
    
    stop("Not enough values so as to generate a correlogram!")
  }
  
  big_data <- na.omit(big_data) # listwise deletion of missing
  big_data <- scale(big_data) # standardize variables
  
  # Determine number of clusters
  wss <- (nrow(big_data)-1)*sum(apply(big_data,2,var))
  for (i in 2:15) wss[i] <- sum(kmeans(big_data, 
                                       centers=i)$withinss)
  plot(1:15, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
  
  # K-Means Cluster Analysis
  fit <- kmeans(big_data, 3) # 5 cluster solution
  # get cluster means 
  aggregate(big_data,by=list(fit$cluster),FUN=mean)
  # append cluster assignment
  big_data <- data.frame(big_data, fit$cluster)
  
  # K-Means Clustering with 5 clusters
  fit <- kmeans(big_data, 3)
  
  # Cluster Plot against 1st 2 principal components
  
  # vary parameters for most readable graph
  library(cluster) 
  clusplot(big_data, fit$cluster, color=TRUE, shade=TRUE, labels=3, lines=0)
  
  # Centroid Plot against 1st 2 discriminant functions
  library(fpc)
  plotcluster(big_data, fit$cluster)
  
  # Model Based Clustering
  library(mclust)
  fit <- Mclust(big_data)
  plot(fit) # plot results 
  summary(fit) # display the best model
  
  
}