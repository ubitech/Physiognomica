
# prometheus_url = "http://212.101.173.70:9090/api/v1/query_range?query="
# start = "&start=2018-09-27T10:10:30.781Z"
# end = "&end=2018-09-27T20:11:00.781Z&step"
# step = "=10m"
# start = "2018-09-27T10:10:30.781Z"
# end = "2018-09-27T20:11:00.781Z&step"
# step = "10m"
# metrics_list = c("netdata:lambdaapp:traefik:lambdacoreapp_system_load_load_average{dimension='load1'}", "netdata:lambdaapp:traefik:lambdacoreapp_cgroup_cpu_per_core_percent_average","netdata:lambdaapp:traefik:lambdaproxy_disk_io_kilobytes_persec_average{dimension='writes'}", "netdata:lambdaapp:traefik:lambdacoreapp_system_ipv4_kilobits_persec_average{dimension='received'}", "netdata:lambdaapp:traefik:multfunc_system_entropy_entropy_average", "netdata:lambdaapp:traefik:sumfunc_system_active_processes_processes_average{instance='[fc04:4d1b:4f34:67cc:9986:ecb3:d73b:2990]:19999'}")
# fisiognomica::getCorrelogram(prometheous_url ,start,end,step,metrics_list)
getCorrelogram <- function(prometheus_url,start,end,step,metrics_list){
  start <- paste("&start=" ,start, sep="")
  end <- paste("&end=" ,end, sep="")
  step <- paste("&step=" ,step, sep="")
  print("getCorrelogram")
  #print(metrics_list)
  
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

  finaldata[] <- lapply(finaldata, function(x) {
    if(is.factor(x)) as.numeric(as.character(x)) else x
  })
  sapply(finaldata, class)
  #finaldata <- subset( finaldata, select = -c(timestamp) )
  finaldata$timestamp <-0
  
  #print("finaldata")
  #print(finaldata)
  finaldata <- Filter(function(x) sd(x) != 0, finaldata)
  
  if(length(finaldata)==0){
    
    stop("Not enough values so as to generate a correlogram!")
  }
  
  final_data_column_names <- colnames(finaldata)
  final_data_column_size <- ncol(finaldata)
  
  
  
  usq <- 0
  for(i in 1:final_data_column_size) {
    #print(i)
    usq[i] <- paste("m:" ,i, sep="")
  }
  print(usq)
  
  colnames(finaldata)<-usq
  
  
  metrics_appendix <- data.frame(matrix(unlist(usq)),stringsAsFactors=FALSE)
  names(metrics_appendix) <- c("metric_number")
  metrics_appendix$friendlyName_with_dimensions=final_data_column_names
  metrics_appendix$name <- "NA"
  
  #enrich metrics_apendix
  metrics_name <- 0
  for(i in 1:nrow(metrics_appendix)) {
    row_friendly_name <- metrics_appendix[i,]$friendlyName_with_dimensions
  
      a<- metrics_list[which(metrics_list$friendlyName_with_dimensions== row_friendly_name), ]
      print(toString(a$name))
      metrics_name[i] <- toString(a$name)
  }
  metrics_appendix$name <- metrics_name

  #correlation matrix
  M<-cor(finaldata)

  #corrplot::corrplot(M, type = "upper", tl.pos = "td", method = "circle", tl.cex = 0.4, tl.col = 'black',order = "hclust", diag = FALSE)

  #corrplot::corrplot(M, type = "upper", tl.pos = "td",method = "number", tl.cex = 0.2, tl.col = 'black',order = "hclust", diag = FALSE)
  
  #apply significance--Tasos
  #finaldata_significance <- cor.mtest(finaldata, conf.level= .95)
  #corrplot:corrplot(M, p.mat = finaldata_significance$p, insig = "pch", sig.level = .05)

  # matrix of the p-value of the correlation
  p.mat <- Physiognomica::cor.mtest(finaldata)
  head(p.mat[, 1:5])

  #corrplot::corrplot(M, type="upper", tl.cex = 0.4, order="hclust", p.mat = p.mat, sig.level = 0.05, insig = "blank", diag = FALSE)
  
  corrplot::corrplot(M, type="upper", tl.cex = 0.4, p.mat = p.mat, sig.level = 0.05, insig = "blank", diag = FALSE)
  
  svg("correlogram.svg",width=14,height=7)
  corrplot::corrplot(M, type="upper", tl.cex = 0.4, p.mat = p.mat, sig.level = 0.05, insig = "blank", diag = FALSE)
  dev.off()
  
  write.csv(metrics_appendix, file = "metrics_appendix.csv")
  return (metrics_appendix)
}


# mat : is a matrix of data
# ... : further arguments to pass to the native R cor.test function
cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}
