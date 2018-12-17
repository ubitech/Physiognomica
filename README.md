# Physiognomica
Fisiognomica - A Novel prometheus Data Analytics Profiler
Fisiognomica is a Novel prometheus Data Analytics Profiler. It is an R package that supports a set of functions as presented at the wiki page. The supported funtions are available for execution via an opencpue server. Physiognomica functions can be execute both by R or via opencpu API. Physiognomica functions can be both triggered as separate analysis services or as a analisis fucntion chain. Physiognomica analisis functions can be registered at cloud-apps-profiler project platform or can be used separately.

#### Supported Analysis chain:
<img src="/images/functionchaingeneric.png">

#### Prerequisites:
1. R Project for Statistical Computing mininum version (R version 3.4.4 (2018-03-15))
https://www.r-project.org/
1. Opencpu API for Embedded Scientific Computing
https://www.opencpu.org/
```
# Requires Ubuntu 18.04 (Bionic) or 16.04 (Xenial)
sudo add-apt-repository -y ppa:opencpu/opencpu-2.1
sudo apt-get update 
sudo apt-get upgrade

# Installs OpenCPU server
sudo apt-get install -y opencpu-server
# Done! Open http://yourhost/ocpu in your browser

# Optional: installs rstudio in http://yourhost/rstudio
sudo apt-get install -y rstudio-server 
```
#### License

This component is published under Apache 2.0 license. Please see the LICENSE file for more details.

#### Lead Developers

The following lead developers are responsible for this repository and have admin rights. They can, for example, merge pull requests.

- Eleni Fotopoulou ([@elfo](https://github.com/efotopoulou))
- Anastasios Zafeiropoulos ([@tzafeir ](https://github.com/azafeiropoulos))


Physiognomica functions can be execute both by R or via opencpu API.
Following are presented both ways.

#### Rererences
https://stackoverflow.com/questions/34525173/how-to-create-correlogram-using-d3-as-in-the-example-picture/34539194#34539194

http://jokergoo.github.io/blog/html/large_matrix_circular.html
https://datascience-enthusiast.com/R/Interactive_chord_diagrams_R.html
https://rpsychologist.com/d3/correlation/
https://github.com/mattflor/chorddiag
https://github.com/mattflor/chorddiag/blob/master/man/chorddiag.Rd
https://rdrr.io/github/software-analytics/Rnalytica/man/stepwise.vif.html
https://www.rdocumentation.org/packages/usdm/versions/1.1-18/topics/vif
https://rdrr.io/cran/circlize/man/chordDiagram.html
https://psycnotes.wordpress.com/selecting-and-visualizing-only-significant-correlation-coefficients-in-matrix/ 
https://datascience-enthusiast.com/R/Interactive_chord_diagrams_R.html
https://www.quora.com/Why-do-R-programmers-use-complicated-OpenCPU-for-web-apps-if-they-have-great-Shiny-platform
https://stackoverflow.com/questions/22255465/assign-colors-to-a-range-of-values
https://www.weave.works/blog/distributed-tracing-loki-zipkin-prometheus-mashup/


//Execute from R
------------------------------------------------
#Method 1: Get Maestro Metrics  
prometheous_metrics_per_graph <- "http://212.101.173.70:8080/api/v1/external/applicationInstance/sM7dEiCHRa/metrics"
MyData<-Physiognomica::getMaestroPrometheusMetrics(prometheous_metrics_per_graph)  

#Method 2: Enrich Maestro metrics with Dimensions   
prometheus_url = "http://212.101.173.70:9090"
metrics_list <- Physiognomica::enrichMaestroPrometheusMetricsWithDimensions(prometheus_url, MyData)  

start = "2018-12-14T09:20:30.781Z"
end = "2018-12-14T10:20:10.781Z"
step = "5m"

#Method 3: Generate Correlogram  
#metrics_list <-read.csv(file="MyDataWithDimensions.csv", header=TRUE, sep=",")
metrics_appendix <- Physiognomica::getCorrelogram(prometheus_url,start,end,step,metrics_list)

#Method 3: Generate Chord Diagram  
#metrics_list <-read.csv(file="MyDataWithDimensions.csv", header=TRUE, sep=",")
metrics_appendix <- Physiognomica::getChordDiagram(prometheus_url,start,end,step,metrics_list)

#Method 4: Combine Metrics in plot
m1 <-19
m2 <-43
profiling_type <- "Resource Efficiency"
return_type <- "plot"
Physiognomica::combinePrometheusMetrics_chained_with_correlogram(prometheus_url,start,end,step,metrics_appendix,m1,m2,profiling_type,return_type)


//Execute from Opencpu
--------------------------------------
#Method 1: Get Maestro Metrics  
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getMaestroPrometheusMetrics'  -d "prometheous_metrics_per_graph='http://212.101.173.70:8080/api/v1/external/applicationInstance/sM7dEiCHRa/metrics'"

#Method 2: Enrich Maestro metrics with Dimensions   
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/enrichMaestroPrometheusMetricsWithDimensions'  -d "prometheus_url='http://212.101.173.70:9090'&MyData=x0c11a5af2e80e7"

#Method 3: Generate Correlogram  
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getCorrelogram'  -d "prometheus_url='http://212.101.173.70:9090'&start='2018-12-14T14:20:30.781Z'&end='2018-12-14T15:54:10.781Z'&step='5m'&metrics_list=x0db39378abe230"

#Method 3: Generate ChordDiagram  
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getChordDiagram'  -d "prometheus_url='http://212.101.173.70:9090'&start='2018-12-14T14:00:30.781Z'&end='2018-12-14T15:00:10.781Z'&step='5m'&metrics_list=x0db39378abe230"

#Method 4: Combine Metrics in plot
curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/combinePrometheusMetrics_chained_with_correlogram'  -d "prometheus_url='http://212.101.173.70:9090'&start='2018-12-13T10:00:30.781Z'&end='2018-12-13T11:00:10.781Z'&step='5m'&metrics_appendix=x0db39378abe230&m1=12&m2=24&profiling_type='Resource Efficiency'&return_type='plot'"


curl 'http://212.101.173.35/ocpu/library/Physiognomica/R/getChordDiagram'  








