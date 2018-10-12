# This is an function named 'combinePrometheusMetrics'
# which has as output a visualization of two prometheus metrics
#prometheous_url = "http://212.101.173.70:9090/api/v1/query?query="
#prometheous_url = "http://212.101.173.70:9090/api/v1/query_range?query="
#start = "&start=2018-09-27T10:10:30.781Z"
#end = "&end=2018-09-27T20:11:00.781Z&step"
#step = "=10m"
#period = "[1m]"
#metric1 = "netdata:lambdaapp:traefik:lambdacoreapp_cgroup_cpu_per_core_percent_average"
#metric2 = "netdata:lambdaapp:traefik:lambdaproxy_disk_io_kilobytes_persec_average{dimension=\"writes\"}"
#profiling_type = "Resource Efficiency"
#fisiognomica::combinePrometheusMetrics(prometheous_url,start,stop,step,metric1,metric2,profiling_type)
combinePrometheusMetrics <- function(prometheous_url,start,end,step,metric1,metric2,profiling_type) {

 mydata1 <- convertPrometheusDataToTabularFormat(prometheous_url,metric1,start,end,step)
 mydata2 <- convertPrometheusDataToTabularFormat(prometheous_url,metric2,start,end,step)


 finaldata <- merge(mydata1, mydata2, by = "timestamp")


 basicplot <- ggplot2::qplot(x=finaldata[[colnames(mydata1)[2]]],
                         y=finaldata[[colnames(mydata2)[2]]],
                         data=finaldata,
                         main=profiling_type,
                         xlab=metric1,group=1,
                         ylab=metric2,group=1)+
   ggplot2::geom_line(colour="steelblue") +
   ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1))

 return(basicplot)
}


convertPrometheusDataToTabularFormat <- function(prometheous_url,metric_name,start,end,step) {
  #result1 <-  httr::GET(paste(prometheous_url , "netdata:lambdaapp:traefik:lambdacoreapp_cgroup_cpu_per_core_percent_average", period, sep=""))
  #print(prometheous_url)
  print(paste("execute convertPrometheusDataToTabularFormat for metric ",metric_name, sep=""))
  print(paste(prometheous_url , metric_name, start,end,step, sep=""))
  result1 <-  httr::GET(paste(prometheous_url , metric_name, start,end,step, sep=""))

  data1 <-content(result1)
  metric_name1 <-data1$data$result[[1]]$metric$`__name__`
  metric_name1 <-gsub(":", "_", metric_name1)

  values1 <- data1$data$result[[1]]$values
  mydata1 <- matrix(unlist(values1),  ncol = 2, byrow = TRUE)

  colnames(mydata1) <- c("timestamp", metric_name1)

  #print(mydata1)

  return(mydata1)
}
test <- function() {
  print("hellooooo there")
}