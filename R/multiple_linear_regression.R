multiple_linear_regression <- function(prometheus_url,start,end,step,metrics,enriched){
  
  start <- paste("&start=" ,start, sep="")
  end <- paste("&end=" ,end, sep="")
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
  colnames(finaldata)
  
  finaldata[] <- lapply(finaldata, function(x) {
    if(is.factor(x)) as.numeric(as.character(x)) else x
  })
  
  
  finaldata <- subset( finaldata, select = -c(timestamp) )
  
  
  final_data_column_names <- colnames(finaldata)
  final_data_column_size <- ncol(finaldata)
  nrow(finaldata)
  
  
  usq <- 0
  for(i in 1:final_data_column_size) {
    #print(i)
    usq[i] <- paste("m" ,i, sep="")
  }
  print(usq)
  
  colnames(finaldata)<-usq
  
  
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
  
  colnames(finaldata)
  
  linearMod <- lm(m1 ~ ., data = finaldata) 
  print(linearMod)
  summary(linearMod) 
  
  step.model1 <- stepAIC(linearMod, direction = "both", trace = FALSE)
  summary(step.model1)
  
  linear_regression_variables <- variable.names(step.model1) 
  linear_regression_variables <-linear_regression_variables[-1];
  
  variables_lenght <- length(linear_regression_variables)
  
  num_of_columns <- round(variables_lenght/2)
  
  svg("multiple_linear_regression.svg",width=14,height=7)
  par(mfrow = c(2,num_of_columns)) ## 2 x 2 plots for same model :
  termplot(step.model1,partial.resid=TRUE, col.res = "purple")
  dev.off()
  
  write.csv(metrics_appendix, file = "metrics_appendix.csv")
  
  
  myvars <- c("metric_number", "friendlyName_with_dimensions")
  newdata <- metrics_appendix[myvars]
  names(newdata) <- c("metric_number", "metric_name")
  
  library(sjPlot)
  sjPlot::tab_model(linearMod,use.viewer=FALSE, file="summary_model.html")
  #cat(tab$page.content)
  #htmltools::save_html(tab,file = "summary_model.html")
  
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
  
  
  #library(GGally)
  #ggscatmat(finaldata, columns = 1: ncol(finaldata))
  
}