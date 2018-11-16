# Physiognomica
Fisiognomica - A Novel prometheus Data Analytics Profiler

//Execute from R
------------------------------------------------
prometheous_metrics_per_graph <- "http://212.101.173.70:8080/api/v1/external/applicationInstance/stiHzFchQQ/metrics"
MyData<-Physiognomica::getMaestroPrometheusMetrics(prometheous_metrics_per_graph)

prometheus_url = "http://212.101.173.70:9090"
metrics_list <- Physiognomica::enrichMaestroPrometheusMetricsWithDimensions(prometheus_url, MyData)

start = "2018-11-16T15:20:30.781Z"
end = "2018-11-16T16:00:10.781Z"
step = "5m"

#metrics_list <-read.csv(file="MyDataWithDimensions.csv", header=TRUE, sep=",")
Physiognomica::getCorrelogram(prometheus_url,start,end,step,metrics_list)


//Execute from Opencpu
--------------------------------------

curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getMaestroPrometheusMetrics'  -d "prometheous_metrics_per_graph='http://212.101.173.70:8080/api/v1/external/applicationInstance/stiHzFchQQ/metrics'"

/ocpu/tmp/x0c11a5af2e80e7/R/.val
/ocpu/tmp/x0c11a5af2e80e7/R/getMaestroPrometheusMetrics
/ocpu/tmp/x0c11a5af2e80e7/stdout
/ocpu/tmp/x0c11a5af2e80e7/source
/ocpu/tmp/x0c11a5af2e80e7/console
/ocpu/tmp/x0c11a5af2e80e7/info
/ocpu/tmp/x0c11a5af2e80e7/files/DESCRIPTION


curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/enrichMaestroPrometheusMetricsWithDimensions'  -d "prometheus_url='http://212.101.173.70:9090'&MyData=x0c11a5af2e80e7"

/ocpu/tmp/x0ec5d14e4079f5/R/.val
/ocpu/tmp/x0ec5d14e4079f5/R/enrichMaestroPrometheusMetricsWithDimensions
/ocpu/tmp/x0ec5d14e4079f5/stdout
/ocpu/tmp/x0ec5d14e4079f5/source
/ocpu/tmp/x0ec5d14e4079f5/console
/ocpu/tmp/x0ec5d14e4079f5/info
/ocpu/tmp/x0ec5d14e4079f5/files/DESCRIPTION



curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getCorrelogram'  -d "prometheus_url='http://212.101.173.70:9090'&start='2018-11-16T15:00:30.781Z'&end='2018-11-16T16:00:10.781Z'&step='5m'&metrics_list=x0db39378abe230"

