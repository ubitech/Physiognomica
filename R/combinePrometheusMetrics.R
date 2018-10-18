# This is an function named 'combinePrometheusMetrics'
# which has as output a visualization of two prometheus metrics
#prometheus_url = "http://212.101.173.70:9090/api/v1/query?query="
#prometheus_url = "http://212.101.173.70:9090/api/v1/query_range?query="
#start = "&start=2018-09-27T10:10:30.781Z"
#end = "&end=2018-09-27T20:11:00.781Z&step"
#step = "=10m"
#period = "[1m]"
#metric1 = "netdata:lambdaapp:traefik:lambdacoreapp_cgroup_cpu_per_core_percent_average"
#metric2 = "netdata:lambdaapp:traefik:lambdaproxy_disk_io_kilobytes_persec_average{dimension=\"writes\"}"
#profiling_type = "Resource Efficiency"
#fisiognomica::combinePrometheusMetrics(prometheus_url,start,stop,step,metric1,metric2,profiling_type)
combinePrometheusMetrics <- function(prometheus_url,start,end,step,metric1,metric2,profiling_type) {
  print("end")
  print(end)
  
 mydata1 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(metric1$name),toString(metric1$friendlyName),toString(metric1$dimensions),start,end,step)
 mydata2 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(metric2$name),toString(metric2$friendlyName),toString(metric2$dimensions),start,end,step)

  

 
 x_axis_name <-paste(toString(metric1$friendlyName),toString(metric1$dimensions),sep="")
 y_axis_name <-paste(toString(metric2$friendlyName),toString(metric2$dimensions),sep="")
 
 finaldata <- merge(mydata1, mydata2, by = "timestamp")
 
 
 basicplot <- ggplot2::qplot(x=finaldata[[colnames(mydata1)[2]]],
                         y=finaldata[[colnames(mydata2)[2]]],
                         data=finaldata,
                         main=profiling_type,
                         xlab=substr(x_axis_name, 1, 30),
                         ylab=substr(y_axis_name, 1, 30),group=1)+
   ggplot2::geom_line(colour="steelblue") +
   ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1))

 label<-paste("Full Axis Names are as follows:\n X-axis:\n",metric1$friendlyName, "\n Y-axis:\n", metric2$friendlyName) 
 p2 <- cowplot::add_sub(basicplot, label, x = 0.5, y = 0.5, hjust = 0.5, vjust = 0.5,
         vpadding = grid::unit(1, "lines"), fontfamily = "", fontface = "plain",
         colour = "blue", size = 6, angle = 0, lineheight = 0.9)
 cowplot::ggdraw(p2)
 

 
 
 return(basicplot)
}


convertPrometheusDataToTabularFormat <- function(prometheous_url,metric_name,metric_friendlyName,dimensions,start,end,step) {

    empty_matrix <-matrix(, nrow = 0, ncol = 0)
  print(paste("execute convertPrometheusDataToTabularFormat for metric ",metric_name, sep=""))
  
  prometheus_url_query_range <- paste(prometheus_url , "/api/v1/query_range?query=", sep="")
  print(paste(prometheus_url_query_range , metric_name, start,end,step, sep=""))
  result1 <-  httr::GET(paste(prometheus_url_query_range , metric_name, start,end,step, sep=""))

  data1 <-httr::content(result1)
  print ("data1")
  print (data1)
  if (data1=="400 Bad Request"){return (empty_matrix)}
  
  #metric_name1 <-data1$data$result[[1]]$metric$`__name__`
  #metric_name1 <-gsub(":", "_", metric_name1)
  if(length(data1$data$result)==0){
    print(paste("No datapoints found for ",metric_name, sep=""))
    return (empty_matrix)
  }
  values1 <- data1$data$result[[1]]$values
  if (is.null(values1)) {
    print("some null values here")
    return (empty_matrix)
  }else{
      
      mydata1 <- matrix(unlist(values1),  ncol = 2, byrow = TRUE)
      
      
      colnames(mydata1) <- c("timestamp", paste(metric_friendlyName , dimensions, sep=""))
      
      #print(mydata1)
      
      return(mydata1)
    }
  
 
}
test <- function() {
  print("hellooooo there")
  metrics_appendix <- read.csv(file="metrics_appendix.csv", header=TRUE, sep=",")
  metric1 <-metrics_appendix[29,]
  #metric1 <-toString(metric1$name)
  
  metric2 <-metrics_appendix[11,]
  #metric2 <-toString(metric2$name)
  print(end)
  Physiognomica::combinePrometheusMetrics(prometheous_url,start,end,step,metric1,metric2,"Resource Efficiency")
  
}