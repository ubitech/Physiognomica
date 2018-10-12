
# prometheous_url = "http://212.101.173.70:9090/api/v1/query_range?query="
# start = "&start=2018-09-27T10:10:30.781Z"
# end = "&end=2018-09-27T20:11:00.781Z&step"
# step = "=10m"
# metrics_list = c("netdata:lambdaapp:traefik:lambdacoreapp_system_load_load_average{dimension='load1'}", "netdata:lambdaapp:traefik:lambdacoreapp_cgroup_cpu_per_core_percent_average","netdata:lambdaapp:traefik:lambdaproxy_disk_io_kilobytes_persec_average{dimension='writes'}", "netdata:lambdaapp:traefik:lambdacoreapp_system_ipv4_kilobits_persec_average{dimension='received'}", "netdata:lambdaapp:traefik:multfunc_system_entropy_entropy_average", "netdata:lambdaapp:traefik:sumfunc_system_active_processes_processes_average{instance='[fc04:4d1b:4f34:67cc:9986:ecb3:d73b:2990]:19999'}")
# fisiognomica::getCorrelogram(prometheous_url ,start,end,step,metrics_list)
getCorrelogram <- function(prometheous_url,start,end,step,metrics_list){
  print("getCorrelogram")
  print(metrics_list)

  for(i in metrics_list){
    metric_name <-i
    print(metric_name)
  }
  finaldata <- data.frame()
  for(i in metrics_list){
    metric_name <-i
    print(metric_name)
    mydata <- fisiognomica::convertPrometheusDataToTabularFormat(prometheous_url,metric_name,start,end,step)
       if (nrow(finaldata)==0){ finaldata <- mydata}
       else{ finaldata <- merge(finaldata,mydata, by = "timestamp")}
     }

  colnames(finaldata)

  finaldata[] <- lapply(finaldata, function(x) {
    if(is.factor(x)) as.numeric(as.character(x)) else x
  })
  sapply(finaldata, class)
  finaldata <- subset( finaldata, select = -timestamp )

  #correlation matrix
  M<-cor(finaldata)

  corrplot::corrplot(M, type = "upper", tl.pos = "td",
           method = "circle", tl.cex = 0.2, tl.col = 'black',
           order = "hclust", diag = FALSE)

  corrplot::corrplot(M, type = "upper", tl.pos = "td",
                     method = "number", tl.cex = 0.2, tl.col = 'black',
                     order = "hclust", diag = FALSE)


  # matrix of the p-value of the correlation
  p.mat <- cor.mtest(finaldata)
  head(p.mat[, 1:5])
  corrplot::corrplot(M, type="upper", tl.cex = 0.3, order="hclust",
                     tl.srt=60, #Text label color and rotation
           p.mat = p.mat, sig.level = 0.05, diag = FALSE)

  corrplot::corrplot(M, type="upper", tl.cex = 0.2, order="hclust",
                     p.mat = p.mat, sig.level = 0.05, insig = "blank", diag = FALSE)


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
