getChordDiagram <- function(prometheus_url,start,end,step,metrics_list){
  start <- paste("&start=" ,start, sep="")
  end <- paste("&end=" ,end, sep="")
  step <- paste("&step=" ,step, sep="")
  print("getCorrelogram")
  #print(metrics_list)
  
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
  #print(finaldata)
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
  
  metrics_appendix_simple <- dplyr::select(metrics_appendix, metric_number,friendlyName_with_dimensions)
 
  
  write.csv(metrics_appendix, file = "metrics_appendix.csv")
  write.csv(metrics_appendix_simple, file = "metrics_appendix_simple.csv")
  
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
    #print(subset)
    usdm::vif(subset) 
    
    v1 <- usdm::vifcor(subset, th=0.90) # identify collinear variables that should be excluded
    re1 <- usdm::exclude(subset,v1) # exclude the collinear variables that were identified in the previous step
    print(re1)
    finaldata_without_group_dimensions_colianearity <- cbind(finaldata_without_group_dimensions_colianearity,re1)
  }
  finaldata_without_group_dimensions_colianearity <- finaldata_without_group_dimensions_colianearity[,-1] 

  dim(finaldata)
  dim(finaldata_without_group_dimensions_colianearity)
  
  #----------------------------------------------

  #usdm::vif(finaldata_without_group_dimensions_colianearity) 
  #v1 <- usdm::vifcor(finaldata_without_group_dimensions_colianearity, th=0.90) # identify collinear variables that should be excluded
  #re1 <- usdm::exclude(finaldata_without_group_dimensions_colianearity,v1) # exclude the collinear variables that were identified in the previous step
  
  #dim(re1)
  
  output = psych::corr.test(finaldata_without_group_dimensions_colianearity)
  A = output$r    # matrix A here contains the correlation coefficients
  B = output$p   # matrix B here contains the corresponding p-values
  
  sig_matrix = ifelse(B > 0.05, A, 0)
  sig_matrix[sig_matrix ==1] <- 0
  
  #--------ChordDiagram total--------------------------------------
  sig_matrix_total<-abs(sig_matrix)
  sig_matrix_total[sig_matrix_total < 0.6] <- 0
  sig_matrix_total<-sig_matrix_total*100
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
 

  
  mychord_negative_to_retunr <- htmlwidgets::saveWidget(mychord_negative, file = "mychordNegative.html")
  mychord_positive_to_retunr <- htmlwidgets::saveWidget(mychord_positive, file = "mychordPositive.html")
  
  #library(htmltools)
  widgets <- list(mychord_negative, mychord_positive)
  fns <- list("mychordNegative.html","mychordPositive.html","metrics_appendix.html")
  

  ititles <- lapply(fns, function(fn)  
    shiny::tags$div(
      shiny::tags$h3(fn, style="float: right;margin-left:300px;")

  ))
  
  iframes <- lapply(fns, function(fn) 
    shiny::tags$iframe(
      src = paste0("http://212.101.173.35:8787/files/Physiognomica/", fn), 
      style="float: right;", 
      width="500",height="500"
    )
  )
  page_body <- shiny::tags$html(
    shiny::tags$body(
      ititles,
      shiny::tags$div(style="clear:both"),
      iframes
    )
  ) 
 return (htmltools::save_html(page_body,file = "index.html"))

  
 #check colors with chordiagram
 #-------------------------------------------
 #values <- c(0.104654225, 0.001781299, 0.343747296, 0.139326617, 0.375521201, 0.101218053)
 #as.vector(sig_matrix_positive)
 #rr <- range( as.vector(sig_matrix_positive))
 #svals <- (sig_matrix_positive-rr[1])/diff(rr)
 ## Play around with ends of the color range
 #f <- colorRamp(c("lightblue", "blue"))
 #groupColors <- rgb(f(svals)/255)
 ## Check that it works
 #image(seq_along(svals), 1, as.matrix(seq_along(svals)), col=groupColors, axes=FALSE, xlab="", ylab="")
 #chorddiag::chorddiag(sig_matrix_positive,groupColors = groupColors,groupnamePadding = 3,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30,showTicks = FALSE)
  
  #m <- matrix(c(0,  5871, 8916, 2868,1951, 10048, 0, 6171, 8010, 16145, 8090, 8045,1013,   990,  940, 0),byrow = TRUE,nrow = 4, ncol = 4)
  #haircolors <- c("black", "blonde", "brown", "red")
  #dimnames(m) <- list(have = haircolors, prefer = haircolors)
  #groupColors <- c("#000000", "#FFDD89", "#957244", "#F26223")
  #chorddiag::chorddiag(m, groupColors = groupColors, groupnamePadding = 20)
  
  
  #rbPal <- colorRampPalette(c('red','blue'))
  #groupColors <- rbPal(10)
  #chorddiag::chorddiag(m, groupColors = groupColors, groupnamePadding = 20)
  
  
  #make use of findcorrelation
  #-------------------------------------------
  #M<-cor(finaldata)
  #dim(M)
  #highlyCorrelated <- caret::findCorrelation(M, cutoff=(0.90),verbose = FALSE)
  #important_metrics = M[-highlyCorrelated,-highlyCorrelated]
  #dim(important_metrics)
}