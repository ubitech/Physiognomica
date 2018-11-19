# Physiognomica
Fisiognomica - A Novel prometheus Data Analytics Profiler

Physiognomica functions can be execute both by R or via opencpu API.
Following are presented both ways.

//Execute from R
------------------------------------------------
Method 1: Get Maestro Metrics  
prometheous_metrics_per_graph <- "http://212.101.173.70:8080/api/v1/external/applicationInstance/stiHzFchQQ/metrics"
MyData<-Physiognomica::getMaestroPrometheusMetrics(prometheous_metrics_per_graph)  

Method 2: Enrich Maestro metrics with Dimensions   
prometheus_url = "http://212.101.173.70:9090"
metrics_list <- Physiognomica::enrichMaestroPrometheusMetricsWithDimensions(prometheus_url, MyData)  

start = "2018-11-16T15:20:30.781Z"
end = "2018-11-16T16:00:10.781Z"
step = "5m"

Method 3: Generate Correlogram  
#metrics_list <-read.csv(file="MyDataWithDimensions.csv", header=TRUE, sep=",")
Physiognomica::getCorrelogram(prometheus_url,start,end,step,metrics_list)


//Execute from Opencpu
--------------------------------------
Method 1: Get Maestro Metrics  
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getMaestroPrometheusMetrics'  -d "prometheous_metrics_per_graph='http://212.101.173.70:8080/api/v1/external/applicationInstance/stiHzFchQQ/metrics'"

Method 2: Enrich Maestro metrics with Dimensions   
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/enrichMaestroPrometheusMetricsWithDimensions'  -d "prometheus_url='http://212.101.173.70:9090'&MyData=x0c11a5af2e80e7"

Method 3: Generate Correlogram  
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getCorrelogram'  -d "prometheus_url='http://212.101.173.70:9090'&start='2018-11-16T15:00:30.781Z'&end='2018-11-16T16:00:10.781Z'&step='5m'&metrics_list=x0db39378abe230"

