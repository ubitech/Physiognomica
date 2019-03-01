library(xts)
library(fpp2)

#start="&start=2019-02-28T10:10:30.781Z"
#end="&end=2019-02-28T16:11:00.781Z"
#step="&step=1m"
#prometheus_url <- "http://212.101.173.70:9090"
#metric1 <- data.frame("name","friendlyName","dimensions")
#metric1$name<-"netdata:7R1uvgJkiZ:LSV6CW7FrZ:d26qWBB8b0_users_cpu_system_cpu_time___average{chart='users.cpu_system',dimension='netdata',family='cpu',instance='[fcef:ef08:3ddd:601a:3805:acf7:df34:ea8f]:19999',job='netdata'}"
#metric1$friendlyName<-"netdata:7R1uvgJkiZ:LSV6CW7FrZ:d26qWBB8b0_users_cpu_system_cpu_time___average{chart='users.cpu_system',dimension='netdata',family='cpu',instance='[fcef:ef08:3ddd:601a:3805:acf7:df34:ea8f]:19999',job='netdata'}"
#metric1$dimensions<-"{chart='users.cpu_system',dimension='netdata',family='cpu',instance='[fcef:ef08:3ddd:601a:3805:acf7:df34:ea8f]:19999',job='netdata'}"


timeSeriesDecomposition <- function(prometheus_url,start,end,step,metric){
  print("time series decomposition")
  mydata1 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(metric1$name),toString(metric1$friendlyName),toString(metric1$dimensions),start,end,step)
  mydata1<-as.data.frame(mydata1)
  
###########################################################
  names(mydata1) <- c("timestamp", "metric")
  summary(mydata1)
  head(mydata1)  

  
###########################################################
  mydata1
  write.csv(mydata1, file = "timeseriesexample.csv")
  options(digits=20)
  mydata1$timestamp <- as.numeric(as.character(mydata1$timestamp))
  mydata1$timestamp <- as.POSIXct(mydata1$timestamp, origin="1970-01-01")
  
  head(mydata1)
  names(mydata1) <- c("timestamp", "metric")
  
  mydata1_ts <- xts(x=mydata1$metric, order.by = mydata1$timestamp)
  mdsts = as.ts(mydata1_ts)
  
  ggplot2::autoplot(mydata1_ts)
  ggplot2::autoplot(mdsts)
  
#  autoplot(mydata1_ts) +
#     forecast::autolayer(meanf(mydata1_ts, h=24), PI=FALSE, series="Mean") +
#     forecast::autolayer(naive(mydata1_ts, h=24), PI=FALSE, series="Naïve") +
#     forecast::autolayer(snaive(mydata1_ts, h=24), PI=FALSE, series="Seasonal naïve")
#   
#   fit <- mydata1_ts %>% decompose(type="additive")
#   
#   autoplot(mydata1_ts, series="Data") +
#     forecast::autolayer(trendcycle(fit), series="Trend") +
#     forecast::autolayer(seasadj(fit), series="Seasonally Adjusted")
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