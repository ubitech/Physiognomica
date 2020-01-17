correlogram <- function(prometheus_url,periods,step,metrics,enriched){
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
  for(i in 1:nrow(periods)) {
    #print(periods[i, "start"])
    start <- paste("&start=" ,periods[i, "start"], sep="")
    end <- paste("&end=" ,periods[i, "end"], sep="")
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
    colnames(finaldata)
    datalist[[i]] <-finaldata
    
    }
  
  big_data = do.call(rbind, datalist)
  
  big_data[] <- lapply(big_data, function(x) {
    if(is.factor(x)) as.numeric(as.character(x)) else x
  })
  sapply(big_data, class)
  #big_data <- subset( big_data, select = -c(timestamp) )
  big_data$timestamp <-0
  
  #print(big_data)
  big_data <- Filter(function(x) sd(x) != 0, big_data)
  
  if(length(big_data)==0){
    
    #stop("Not enough values so as to generate a correlogram!")
    ibody <- shiny::tags$div(shiny::tags$h3("Not enough values so as to generate a correlogram!"))
    page_body <- shiny::tags$html(shiny::tags$body(ibody)) 
    htmltools::save_html(page_body,file = "correlogram.html")
    return ()
  }
  
  final_data_column_names <- colnames(big_data)
  final_data_column_size <- ncol(big_data)
  
  
  
  usq <- 0
  for(i in 1:final_data_column_size) {
    #print(i)
    usq[i] <- paste("m:" ,i, sep="")
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
  
  #correlation matrix
  M<-cor(big_data)
  
  # matrix of the p-value of the correlation
  p.mat <- Physiognomica::cor.mtest(big_data)
  head(p.mat[, 1:5])

  svg("correlogram.svg",width=14,height=7)
  corrplot::corrplot(M, type="upper", tl.cex = 0.4, p.mat = p.mat, sig.level = 0.01, insig = "blank", diag = FALSE)
  dev.off()
  
  write.csv(metrics_appendix, file = "metrics_appendix.csv")
  
  myvars <- c("metric_number", "friendlyName_with_dimensions")
  newdata <- metrics_appendix[myvars]
  names(newdata) <- c("metric_number", "metric_name")
  
  ibody <- 
    shiny::tags$div(shiny::tags$h3("Correlogram with statistical significant correlations of 0.01:"),
                    shiny::tags$img(src = "correlogram.svg"))
  
  page_body <- shiny::tags$html(
    shiny::tags$body(
      ibody,
      tableHTML::tableHTML(newdata)
    )
  ) 
  htmltools::save_html(page_body,file = "correlogram.html")
  
  return (metrics_appendix)
}


# mat : is a matrix of data
# ... : further arguments to pass to the native R cor.test function
cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}
