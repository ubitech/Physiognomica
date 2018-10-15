# Physiognomica
Fisiognomica - A Novel prometheus Data Analytics Profiler

prometheous_metrics_per_graph <- "http://212.101.173.70:8080/api/v1/external/applicationInstance/EQRJJZRkfU/metrics"

Physiognomica::getMaestroPrometheusMetrics(prometheous_metrics_per_graph)
prometheus_url = "http://212.101.173.70:9090"
Physiognomica::enrichMaestroPrometheusMetricsWithDimensions(prometheus_url, MyData)

start = "&start=2018-10-15T13:40:30.781Z"
end = "&end=2018-10-15T14:50:00.781Z&step"
step = "=10m"

Physiognomica::getCorrelogram(prometheus_url,start,end,step,metrics_list)
