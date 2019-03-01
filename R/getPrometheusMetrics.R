#prometheous_metrics_per_graph <- "http://212.101.173.70:8080/api/v1/external/applicationInstance/EQRJJZRkfU/metrics"
getMaestroPrometheusMetrics <- function(prometheous_metrics_per_graph){
  print("get full set of prometheus metrics list of a specific graph")
  
  #preselected_metrics <- read.csv(file="/home/rstudio/PreselectedMetrics.csv", header=TRUE, sep=",")
  preselected_metrics <- read.csv(url("http://212.101.173.35/Physiognomica/PreselectedMetrics.csv"),header=TRUE, sep=",")
  
  friendly_preselected_metrics <- preselected_metrics$friendlyName
  
  result1 <-  httr::GET(prometheous_metrics_per_graph)
  data1 <-httr::content(result1)
  applicationName <- data1$applicationName
  
  data1$applicationInstanceHexID
  data1$applicationHexID
  
  components <- data1$components
  
  metrics_dataframe <- data.frame(Characters=character(),Characters=character(),stringsAsFactors=FALSE)
  colnames(metrics_dataframe) <- c("name","friendlyName")
  
  for(i in components){
    print(i$hexID);
    component_metrics <- i$metrics
    
    for(m in component_metrics){
      metric_name <- paste("netdata:" , data1$applicationHexID, ":",data1$applicationInstanceHexID,":",i$hexID,m$name, sep="")
      metric_friendlyName <- m$friendlyName
      
      #print(metric_name);
      #print(metric_friendlyName);
      newRow <- data.frame(name=metric_name,friendlyName=metric_friendlyName)
      
      if(metric_friendlyName %in% friendly_preselected_metrics){
        
        print(metric_friendlyName)
        print("Found the metric!")
        metrics_dataframe <- rbind(metrics_dataframe,newRow)
      }
    }
  }
  
  #metrics_dataframe
  
  #write.csv(metrics_dataframe, file = "MyData.csv")
  return (metrics_dataframe)
 
}
#prometheus_url = "http://212.101.173.70:9090"
enrichMaestroPrometheusMetricsWithDimensions <- function(prometheus_url,MyData){
  prometheous_url <- paste(prometheus_url,"/api/v1/series?match[]=", sep="")
  
  #MyData <- read.csv(file="MyData.csv", header=TRUE, sep=",")
  MyData$name
  
  complete_metrics_dataframe <- data.frame(Characters=character(),Characters=character(),Characters=character(),Characters=character(),stringsAsFactors=FALSE)
  colnames(complete_metrics_dataframe) <- c("name","friendlyName","dimensions","friendlyName_with_dimensions")
  
  for(i in 1:nrow(MyData)) {
    row <- MyData[i,]
    prometheous_match_query <- paste(prometheous_url,row$name, sep="")
    print(prometheous_match_query)
    result1 <-  httr::GET(prometheous_match_query)
    data1 <-httr::content(result1)
    print(data1$data)
    list_of_dimensions <- data1$data
    
    for(i in list_of_dimensions){
     # print(i$chart)
      
      complete_metric_name <-  paste(row$name,"{chart='",i$chart,"',",
                                     "dimension='",i$dimension,"',",
                                     "family='",i$family,"',",
                                     "instance='",i$instance,"',",
                                     "job='",i$job,"'}",
                                     sep="")
      
      complete_metric_friendlyName <- row$friendlyName
      dimensions <- paste("{chart='",i$chart,"',",
                                            "dimension='",i$dimension,"',",
                                            "family='",i$family,"',",
                                            "instance='",i$instance,"',",
                                            "job='",i$job,"'}",
                                            sep="")
      friendlyName_with_dimensions <- paste(row$friendlyName,"{chart='",i$chart,"',",
                          "dimension='",i$dimension,"',",
                          "family='",i$family,"',",
                          "instance='",i$instance,"',",
                          "job='",i$job,"'}",
                          sep="")
      
     
      
      newRow <- data.frame(name=complete_metric_name,friendlyName=complete_metric_friendlyName,dimensions=dimensions,friendlyName_with_dimensions=friendlyName_with_dimensions)
      
      complete_metrics_dataframe <- rbind(complete_metrics_dataframe,newRow)
    }
  }
  
  #metrics_list <- complete_metrics_dataframe$name
  #write.csv(complete_metrics_dataframe, file = "MyDataWithDimensions.csv")
  metrics_list <- complete_metrics_dataframe
  
  return (metrics_list)
  
}
#Enrich with dimensions a set of prometheus metrics
#prometheus_url = "http://212.101.173.70:9090"
enrichMaestroPrometheusMetricsWithDimensionsWithoutSession <- function(prometheus_url,metrics){
  prometheous_url <- paste(prometheus_url,"/api/v1/series?match[]=", sep="")
  
  complete_metrics_dataframe <- data.frame(Characters=character(),Characters=character(),Characters=character(),Characters=character(),stringsAsFactors=FALSE)
  colnames(complete_metrics_dataframe) <- c("name","friendlyName","dimensions","friendlyName_with_dimensions")
  
  for(row in metrics) {
    prometheous_match_query <- paste(prometheous_url,row, sep="")
    print(prometheous_match_query)
    result1 <-  httr::GET(prometheous_match_query)
    data1 <-httr::content(result1)
    print(data1$data)
    list_of_dimensions <- data1$data
    
    for(i in list_of_dimensions){
      # print(i$chart)
      
      complete_metric_name <-  paste(row,"{chart='",i$chart,"',",
                                     "dimension='",i$dimension,"',",
                                     "family='",i$family,"',",
                                     "instance='",i$instance,"',",
                                     "job='",i$job,"'}",
                                     sep="")
      
      complete_metric_friendlyName <- row
      dimensions <- paste("{chart='",i$chart,"',",
                          "dimension='",i$dimension,"',",
                          "family='",i$family,"',",
                          "instance='",i$instance,"',",
                          "job='",i$job,"'}",
                          sep="")
      friendlyName_with_dimensions <- paste(row,"{chart='",i$chart,"',",
                                            "dimension='",i$dimension,"',",
                                            "family='",i$family,"',",
                                            "instance='",i$instance,"',",
                                            "job='",i$job,"'}",
                                            sep="")
      
      
      
      newRow <- data.frame(name=complete_metric_name,friendlyName=complete_metric_friendlyName,dimensions=dimensions,friendlyName_with_dimensions=friendlyName_with_dimensions)
      
      complete_metrics_dataframe <- rbind(complete_metrics_dataframe,newRow)
    }
  }
  
  #metrics_list <- complete_metrics_dataframe$name
  #write.csv(complete_metrics_dataframe, file = "MyDataWithDimensions.csv")
  metrics_list <- complete_metrics_dataframe
  
  return (metrics_list)
  
}
hello <- function(){
  print("Hello from Physiognomica!")
  print("Let's do some profiling!")
}
