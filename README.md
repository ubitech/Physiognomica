# Physiognomica
Fisiognomica - A Novel prometheus Data Analytics Profiler

Physiognomica functions can be execute both by R or via opencpu API.
Following are presented both ways.

//Execute from R
------------------------------------------------
#Method 1: Get Maestro Metrics  
prometheous_metrics_per_graph <- "http://212.101.173.70:8080/api/v1/external/applicationInstance/stiHzFchQQ/metrics"
MyData<-Physiognomica::getMaestroPrometheusMetrics(prometheous_metrics_per_graph)  

#Method 2: Enrich Maestro metrics with Dimensions   
prometheus_url = "http://212.101.173.70:9090"
metrics_list <- Physiognomica::enrichMaestroPrometheusMetricsWithDimensions(prometheus_url, MyData)  

start = "2018-11-19T13:54:30.781Z"
end = "2018-11-19T14:54:10.781Z"
step = "5m"

#Method 3: Generate Correlogram  
#metrics_list <-read.csv(file="MyDataWithDimensions.csv", header=TRUE, sep=",")
metrics_appendix <- Physiognomica::getCorrelogram(prometheus_url,start,end,step,metrics_list)

#Method 4: Combine Metrics in plot
m1 <-19
m2 <-43
profiling_type <- "Resource Efficiency"
return_type <- "plot"
Physiognomica::combinePrometheusMetrics_chained_with_correlogram(prometheus_url,start,end,step,metrics_appendix,m1,m2,profiling_type,return_type)


//Execute from Opencpu
--------------------------------------
#Method 1: Get Maestro Metrics  
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getMaestroPrometheusMetrics'  -d "prometheous_metrics_per_graph='http://212.101.173.70:8080/api/v1/external/applicationInstance/stiHzFchQQ/metrics'"

#Method 2: Enrich Maestro metrics with Dimensions   
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/enrichMaestroPrometheusMetricsWithDimensions'  -d "prometheus_url='http://212.101.173.70:9090'&MyData=x0c11a5af2e80e7"

#Method 3: Generate Correlogram  
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getCorrelogram'  -d "prometheus_url='http://212.101.173.70:9090'&start='2018-11-19T13:54:30.781Z'&end='2018-11-19T14:54:10.781Z'&step='5m'&metrics_list=x0db39378abe230"

#Method 4: Combine Metrics in plot
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/combinePrometheusMetrics_chained_with_correlogram'  -d "prometheus_url='http://212.101.173.70:9090'&start='2018-11-19T13:54:30.781Z'&end='2018-11-19T14:54:10.781Z'&step='5m'&metrics_appendix=x0db39378abe230&m1=12&m2=24&profiling_type='Resource Efficiency'&return_type='plot'"


Notes:
For better visualization
https://stackoverflow.com/questions/34525173/how-to-create-correlogram-using-d3-as-in-the-example-picture/34539194#34539194

