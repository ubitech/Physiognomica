#metrics are without dimensions
getChordDiagramFromPrometheusMetrics <- function(prometheus_url,start,end,step,metrics,enriched){
  
  if (isTRUE(enriched)){
    print("i am enriched")
    metrics_list =data.frame(name=metrics,friendlyName=metrics,dimensions = stringr::str_extract(metrics, stringr::regex("\\{.*\\}")))
  }
  else{
    #enrichMaestroPrometheusMetricsWithDimensionsWithoutSession
    metrics_list <- Physiognomica::enrichMaestroPrometheusMetricsWithDimensionsWithoutSession(prometheus_url,metrics)
  }
  
  
  start <- paste("&start=" ,start, sep="")
  end <- paste("&end=" ,end, sep="")
  step <- paste("&step=" ,step, sep="")
  print("getCorrelogram")
  
  for(i in metrics_list) {
    print(i)
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
    sapply(finaldata, class)
    #finaldata <- subset( finaldata, select = -c(timestamp) )
    finaldata$timestamp <-0
    
    #print("finaldata")
    print(finaldata)
    finaldata <- Filter(function(x) sd(x) != 0, finaldata)
    
    if(length(finaldata)==0){
      
      stop("Not enough values so as to generate a correlogram!")
    }
    
    final_data_column_names <- colnames(finaldata)
    final_data_column_size <- ncol(finaldata)
    
    usq <- 0
    for(i in 1:final_data_column_size) {
      #print(i)
      usq[i] <- paste("m_" ,i, sep="")
    }
    print(usq)
    
    colnames(finaldata)<-usq
    
    
    metrics_appendix <- data.frame(matrix(unlist(usq)),stringsAsFactors=FALSE)
    names(metrics_appendix) <- c("metric_number")
    metrics_appendix$friendlyName_with_dimensions=final_data_column_names
    metrics_appendix$name <- "NA"
    
    #enrich metrics_apendix
    metrics_name <- 0
    metrics_friendlyname <- 0
    for(i in 1:nrow(metrics_appendix)) {
      row_friendly_name <- metrics_appendix[i,]$friendlyName_with_dimensions
      
      a<- metrics_list[which(metrics_list$friendlyName_with_dimensions== row_friendly_name), ]
      print(toString(a$name))
      metrics_name[i] <- toString(a$name)
      metrics_friendlyname[i] <- toString(a$friendlyName)
    }
    metrics_appendix$name <- metrics_name
    metrics_appendix$friendlyName <- metrics_friendlyname
    
    #metrics_appendix_simple <- dplyr::select(metrics_appendix, metric_number,friendlyName_with_dimensions)
    
    
    write.csv(metrics_appendix, file = "metrics_appendix.csv")
    #write.csv(metrics_appendix_simple, file = "metrics_appendix_simple.csv")
    
    #----------------------------------------------
    finaldata_without_group_dimensions_colianearity <- 0
    
    unique_friendly_names <- unique(metrics_appendix$friendlyName)
    for(i in unique_friendly_names) {
      unique_row_friendly_name <- i
      a <- metrics_appendix[which(metrics_appendix$friendlyName== unique_row_friendly_name), ]
      print("------------")
      
      dimensions_group <- a$metric_number
      print(dimensions_group)
      print("//////////////")
      subset<- dplyr::select(finaldata, dimensions_group)
      if (ncol(subset)>1){
        usdm::vif(subset) 
        
        v1 <- usdm::vifcor(subset, th=0.90) # identify collinear variables that should be excluded
        re1 <- usdm::exclude(subset,v1) # exclude the collinear variables that were identified in the previous step
        print(re1)
        finaldata_without_group_dimensions_colianearity <- cbind(finaldata_without_group_dimensions_colianearity,re1)
      }else{
        finaldata_without_group_dimensions_colianearity <- cbind(finaldata_without_group_dimensions_colianearity,subset)
      }
      
    }
    finaldata_without_group_dimensions_colianearity <- finaldata_without_group_dimensions_colianearity[,-1] 
    
    dim(finaldata)
    dim(finaldata_without_group_dimensions_colianearity)
    
    #----------------------------------------------
    
    output = psych::corr.test(finaldata_without_group_dimensions_colianearity)
    A = output$r    # matrix A here contains the correlation coefficients
    B = output$p   # matrix B here contains the corresponding p-values
    
    sig_matrix = ifelse(B > 0.05, A, 0)
    sig_matrix[sig_matrix ==1] <- 0
    
    #--------ChordDiagram total--------------------------------------
    sig_matrix_total<-abs(sig_matrix)
    sig_matrix_total[sig_matrix_total < 0.6] <- 0
    sig_matrix_total<-sig_matrix_total*100
    
    
    write.csv(sig_matrix_total, file = "correlation_matrix.csv")
    correlation_matrix_json <- jsonlite::toJSON(sig_matrix_total)
    write(correlation_matrix_json, "correlation_matrix.json")
    
    chorddiag::chorddiag(sig_matrix_total,groupnamePadding = 3,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30,showTicks = FALSE)
    
    #--------ChordDiagram positive--------------------------------------
    sig_matrix_positive <-sig_matrix
    sig_matrix_positive[sig_matrix_positive <0] <- 0
    sig_matrix_positive[sig_matrix_positive < 0.6] <- 0
    sig_matrix_positive<-sig_matrix_positive*100
    mychord_positive <- chorddiag::chorddiag(sig_matrix_positive,groupnamePadding = 3,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30,showTicks = FALSE)
    
    #--------ChordDiagram negative--------------------------------------
    sig_matrix_negative <-sig_matrix
    sig_matrix_negative[sig_matrix_negative >0] <- 0
    sig_matrix_negative[sig_matrix_negative > -0.6] <- 0
    sig_matrix_negative<-sig_matrix_negative*100
    sig_matrix_negative<-abs(sig_matrix_negative)
    chorddiag::chorddiag(sig_matrix_negative,groupnamePadding = 3,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30,showTicks = FALSE, clickAction = "alert( d.source.index);")
    
    mychord_negative <- chorddiag::chorddiag(sig_matrix_negative,groupnamePadding = 3,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30,showTicks = FALSE,tooltipUnit = " %",precision = 4, 
                                             clickAction = "
                                             //alert( JSON.stringify(d));  
                                             //var lala = d.source.index; 
                                             //var url = new URL(document.location);
                                             //var c = url.searchParams.get('c');
                                             //alert(c);
                                             //alert( 'http://212.101.173.35/getscatterplot/'+this.id+'/'+d.source.value);
                                             
                                             var data = null;
                                             var xhr = new XMLHttpRequest();
                                             xhr.addEventListener('readystatechange', function () {
                                             if (this.readyState === 4) {
                                             alert(this.responseText);
                                             window.open( 'http://212.101.173.35/getscatterplot/'+this.id+'/'+d.source.value);
                                             
                                             }
                                             });
                                             xhr.open('POST', 'http://212.101.173.35/ocpu/library/Physiognomica/R/hello/');
                                             xhr.send(data);
                                             ")
    
    
    #mychord_negative_to_retunr <- htmlwidgets::saveWidget(mychord_negative, file = "mychordNegative.html")
    #mychord_positive_to_retunr <- htmlwidgets::saveWidget(mychord_positive, file = "mychordPositive.html")
    
  
    #widgets <- list(mychord_negative, mychord_positive)
    #ititles <- lapply(widgets, function(fn)  
    # shiny::tags$div(
    #   shiny::tags$h3(fn, style="float:left;margin-left:300px;")
    # ))
    
    ititle1 <- 
      shiny::tags$div(shiny::tags$h3("Chord Diagramm with positive and statistical significant correlations"),
        shiny::tags$h3(mychord_positive))
  
    ititle2 <- 
      shiny::tags$div(shiny::tags$h3("Chord Diagramm with negative and statistical significant correlation"),
                      shiny::tags$h3(mychord_negative))
    
    myvars <- c("metric_number", "friendlyName_with_dimensions")
    newdata <- metrics_appendix[myvars]
    names(newdata) <- c("metric_number", "metric_name")
   
    page_body <- shiny::tags$html(
      shiny::tags$body(
        ititle1,
        ititle2,
        #shiny::tags$div(style="clear:both"),
        tableHTML::tableHTML(newdata)
        #iframes
      )
    ) 
    #htmltools::save_html(page_body,file = "index.html")
    #https://stackoverflow.com/questions/17748566/how-can-i-turn-an-r-data-frame-into-a-simple-unstyled-html-table
    #return (htmltools::save_html(page_body,file = "index.html"))
    htmltools::save_html(page_body,file = "correlation_page.html")
    return (correlation_matrix_json)
}