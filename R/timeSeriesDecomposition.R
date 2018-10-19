timeSeriesDecomposition <- function(prometheus_url,start,end,step,metric){
  print("time series decomposition")
  mydata1 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(metric1$name),toString(metric1$friendlyName),toString(metric1$dimensions),start,end,step)
  mydata1<-as.data.frame(mydata1)
  
  mydata1
  options(digits=20)
  mydata1$timestamp <- as.numeric(as.character(mydata1$timestamp))
  mydata1$timestamp <- as.POSIXct(mydata1$timestamp, origin="1970-01-01")
  
}

#prometheus_url = "http://212.101.173.70:9090"
#start = "&start=2018-10-19T07:30:30.781Z"
#end = "&end=2018-10-19T08:30:10.781Z"
#step = "&step=1m"
test_time_series_decomposition <- function() {
print("execute test_time_series_decomposition")
metrics_appendix <- read.csv(file="metrics_appendix.csv", header=TRUE, sep=",")
metric1 <-metrics_appendix[10,]

Physiognomica::timeSeriesDecomposition(prometheus_url,start,end,step,metric1)
}