multiple_linear_regression <- function(prometheus_url,periods,step,metrics,enriched){
  
  #start <- paste("&start=" ,start, sep="")
  #end <- paste("&end=" ,end, sep="")
  step <- paste("&step=" ,step, sep="")
  print("getCorrelogram")
  #print(metrics)
  
  
  if (isTRUE(enriched)){
    print("i am enriched")
    metrics_list =data.frame(name=metrics,friendlyName=metrics,dimensions = stringr::str_extract(metrics, stringr::regex("\\{.*\\}")))
  }
  else{
    #enrichMaestroPrometheusMetricsWithDimensionsWithoutSession
    metrics_list <- Physiognomica::enrichMaestroPrometheusMetricsWithDimensionsWithoutSession(prometheus_url,metrics)
  }
  
  datalist = list()
  for(i in 1:nrow( periods )) {
    #print(periods[i, "start"])
    start <- paste("&start=" , periods[i, "start"], sep="")
    end <- paste("&end=" , periods[i, "end"], sep="")
    #print(start)
    #print(end)
    
    finaldata <- data.frame()
    for(i in 1:nrow(metrics_list)) {
      row <- metrics_list[i,]
      metric_name <-row$name
      metric_friendlyName <-row$friendlyName
      
      dimensions <-row$dimensions
      print("dimensions")
      print(dimensions)
      mydata <- Physiognomica::convertPrometheusDataToTabularFormat(prometheus_url,metric_name,metric_friendlyName,dimensions,start,end,step)
      if (nrow(finaldata)==0){ finaldata <- mydata
      }else{ 
        if (nrow(mydata)!=0){
          finaldata <- merge(x=finaldata,y=mydata, by.x = "timestamp")
        }
      }
    }
    print("get final data")
    #colnames(finaldata)
    datalist[[i]] <- finaldata
  }
  
  big_data = do.call(rbind, datalist)
  
  big_data[] <- lapply(big_data, function(x) {
    if(is.factor(x)) as.numeric(as.character(x)) else x
  })
  
  
  big_data <- subset( big_data, select = -c(timestamp) )
  
  
  final_data_column_names <- colnames(big_data)
  final_data_column_size <- ncol(big_data)
  nrow(big_data)
  
  
  usq <- 0
  for(i in 1:final_data_column_size) {
    #print(i)
    usq[i] <- paste("m" ,i, sep="")
  }
  print(usq)
  
  colnames(big_data)<-usq
  
  
  metrics_appendix <- data.frame(matrix(unlist(usq)),stringsAsFactors=FALSE)
  names(metrics_appendix) <- c("metric_number")
  metrics_appendix$friendlyName_with_dimensions=final_data_column_names
  metrics_appendix$name <- "NA"
  
  #enrich metrics_apendix
  metrics_name <- 0
  for(i in 1:nrow(metrics_appendix)) {
    row_friendly_name <- metrics_appendix[i,]$friendlyName_with_dimensions
    
    a<- metrics_list[which(metrics_list$friendlyName_with_dimensions== row_friendly_name), ]
    print(toString(a$name))
    metrics_name[i] <- toString(a$name)
  }
  metrics_appendix$name <- metrics_name
  
  linearMod <- lm(m1 ~ ., data = big_data) 
  print(linearMod)
  summary(linearMod) 
  
  step.model1 <- MASS::stepAIC(linearMod, direction = "both", trace = FALSE)
  summary(step.model1)
  
  linear_regression_variables <- variable.names(step.model1) 
  linear_regression_variables <- linear_regression_variables[-1];
  
  variables_lenght <- length(linear_regression_variables)
  
  num_of_columns <- round(variables_lenght/2)
  
  svg("multiple_linear_regression.svg",width=14,height=7)
  if (variables_lenght==1){
    par(mfrow = c(1,1)) ## 2 x 1 plots for same model 
  }else{
    par(mfrow = c(2,num_of_columns)) ## 2 x n plots for same model 
  }
  
  termplot(step.model1,partial.resid = TRUE, col.res = "purple")
  dev.off()
  
  write.csv(metrics_appendix, file = "metrics_appendix.csv")
  
  
  myvars <- c("metric_number", "friendlyName_with_dimensions")
  newdata <- metrics_appendix[myvars]
  names(newdata) <- c("metric_number", "metric_name")
  
  sjPlot::tab_model(step.model1,use.viewer=FALSE,show.se=TRUE,show.ci=FALSE)
  
  #library(sjPlot)
  summary_as_html <- sjPlot::tab_model(step.model1,use.viewer=FALSE,show.se=TRUE,show.ci=FALSE, file="summary_model.html")
  
  ibody <- 
    shiny::tags$div(shiny::tags$h3("Multiple linear regression model for metric"),
                    shiny::tags$h4(metrics_appendix[1,2]),
                    shiny::tags$iframe(src = "summary_model.html",scrolling="yes",height="500px",width="400px"),
                    shiny::tags$img(src = "multiple_linear_regression.svg",style="float:right"))
  
  page_body <- shiny::tags$html(
    shiny::tags$body(
      ibody,
      tableHTML::tableHTML(newdata)
    )
  ) 
  htmltools::save_html(page_body,file = "multiple_linear_regression.html")
  return(summary_as_html)
  
}