# Physiognomica
Fisiognomica - A Novel prometheus Data Analytics Profiler

prometheous_metrics_per_graph <- "http://212.101.173.70:8080/api/v1/external/applicationInstance/fTkycV32Mu/metrics"
Physiognomica::getMaestroPrometheusMetrics(prometheous_metrics_per_graph)

prometheus_url = "http://212.101.173.70:9090"
metrics_list <- Physiognomica::enrichMaestroPrometheusMetricsWithDimensions(prometheus_url, MyData)

start = "&start=2018-10-18T10:58:30.781Z"
end = "&end=2018-10-18T12:10:00.781Z&step"
step = "=5m"

#metrics_list <-read.csv(file="MyDataWithDimensions.csv", header=TRUE, sep=",")
Physiognomica::getCorrelogram(prometheus_url,start,end,step,metrics_list)
