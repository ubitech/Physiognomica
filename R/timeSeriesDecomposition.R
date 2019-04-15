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


timeSeriesDecomposition <- function(prometheus_url,start,end,step,metrics,enriched){
  print("time series decomposition")
  
  start <- paste("&start=" ,start, sep="")
  end <- paste("&end=" ,end, sep="")
  step <- paste("&step=" ,step, sep="")
  
  metricname = metrics[1]
  metricfriendlyName = metrics[1]
  metricdimensions = stringr::str_extract(metrics[1], stringr::regex("\\{.*\\}"))
  
  mydata1 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(metricname),toString(metricfriendlyName),toString(metricdimensions),start,end,step)
  mydata1<-as.data.frame(mydata1)
  
  #shorten metric description
  colnames(mydata1)[2] <- "metric1"
  
  # exclude first column
  mydata1 <- mydata1[, -1]  
  head(mydata1)
  
  mydata1_ts <-ts(mydata1, frequency = 10)
  #mydata1_ts <- ts(mydata1, frequency = 10)
  #autoplot(mydata1_ts)
  
  #time series decomposition (additive)
  #mydata1_decomp_add <- decompose(mydata1_ts)
  #plot(mydata1_decomp_add)
  
  #time series decomposition (multiplicative)
  #mydata1_decomp_multi <- decompose(mydata1_ts, type="multiplicative")
  #plot(mydata1_decomp_multi)
  
  #time series decomposition based on stl (“Seasonal Decomposition of Time Series by LOESS”)
  fit = stl(mydata1_ts, s.window = "periodic")
  
  jpeg('tm_series_decomposition.jpg')
  plot(fit)
  dev.off()
  
  mn <- toString(metric_name)
  metric_name_without_dimensions <- strsplit( mn, "\\{")[[1]][1]
  dimensions <- stringr::str_extract( mn, stringr::regex("\\{.*\\}"))
  
  ibody <- 
    shiny::tags$div(shiny::tags$h3("Time Series decomposition for metric:"),
                    shiny::tags$h4(metric_name_without_dimensions),
                    shiny::tags$h4(dimensions),
                    shiny::tags$img(src = "tm_series_decomposition.jpg"))
  
  page_body <- shiny::tags$html(
    shiny::tags$body(
      ibody
    )
  ) 
  htmltools::save_html(page_body,file = "time_series_decomposition.html")
  
  #fit2 = stl(mydata1_ts, s.window = "periodic", t.window = 15)
  #plot(fit2)
  
###########################################################
  #names(mydata1) <- c("timestamp", "metric")
  #summary(mydata1)
  #head(mydata1)  
  #ts_mydata1 <- as.ts(mydata1)

  #ts_mydata1 %>% decompose(type="additive")
  
###########################################################
  #mydata1
  #write.csv(mydata1, file = "timeseriesexample.csv")
  #options(digits=20)
  #mydata1$timestamp <- as.numeric(as.character(mydata1$timestamp))
  #mydata1$timestamp <- as.POSIXct(mydata1$timestamp, origin="1970-01-01")
  
  #head(mydata1)
  #names(mydata1) <- c("timestamp", "metric")
  
  #mydata1_ts <- xts(x=mydata1$metric, order.by = mydata1$timestamp)
  #mdsts = as.ts(mydata1_ts)
  
  #ggplot2::autoplot(mydata1_ts)
  #ggplot2::autoplot(mdsts)
  
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