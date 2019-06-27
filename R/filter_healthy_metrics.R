filter_healthy_metrics <- function(prometheus_url,periods,step,metrics,enriched) {
  
  step <- paste("&step=" ,step, sep="")
  for(i in 1:nrow(periods)) {
    #print(periods[i, "start"])
    start <- paste("&start=" ,periods[i, "start"], sep="")
    end <- paste("&end=" ,periods[i, "end"], sep="")
  }
  metrics_list = data.frame(name=metrics,friendlyName=metrics,dimensions = stringr::str_extract(metrics, stringr::regex("\\{.*\\}")))
  print(metrics_list)
  unhealthy_metrics_list = NULL
  healthy_metrics_list = NULL
  for(i in 1:nrow(metrics_list)) {
    row <- metrics_list[i,]
    metric_name <-row$name
    metric_friendlyName <-row$friendlyName
    dimensions <-row$dimensions
    mydata <- Physiognomica::convertPrometheusDataToTabularFormat(prometheus_url,metric_name,metric_friendlyName,dimensions,start,end,step)
    #print("mydata")
    #print(mydata)
    if (nrow(mydata)==0){
       print("---empty metric name---")  
       print(metric_name)
       unhealthy_metrics_list<- append(unhealthy_metrics_list,toString(metric_name))
      }else if(length(unique(mydata[,2]))==1) {
       print("---stable metric name---")  
       print(metric_name)
       unhealthy_metrics_list<- append(unhealthy_metrics_list,toString(metric_name))
       }else{
      healthy_metrics_list<- append(healthy_metrics_list,toString(metric_name))
      }
   
  }
  
  healthy_metrics_json <- jsonlite::toJSON(healthy_metrics_list)
  write(healthy_metrics_json, "healthy_metrics.json")
  
  unhealthy_metrics_json <- jsonlite::toJSON(unhealthy_metrics_list)
  write(unhealthy_metrics_json, "unhealthy_metrics.json")
  
  healthy_percentage = (length(healthy_metrics_list)/nrow(metrics_list))*100
  
  ibody <- 
    shiny::tags$div(shiny::tags$h3(paste("The set of metrics is " ,healthy_percentage,"% healthy", sep="")))
  
  page_body <- shiny::tags$html(
    shiny::tags$body(
      ibody
      #shiny::tags$div(shiny::tags$h3("unhealthy metrics"))
      #tableHTML::tableHTML(unhealthy_metrics_list)
    )
  ) 
  htmltools::save_html(page_body,file = "filter_healthy_metrics.html")  
  
  return (healthy_percentage)
  
}