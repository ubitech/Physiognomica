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
  write.csv(metrics_appendix, file = "metrics_appendix.csv")
  
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
    subset<- select(finaldata, dimensions_group)
    #print(subset)
    usdm::vif(subset) 
    
    v1 <- usdm::vifcor(subset, th=0.90) # identify collinear variables that should be excluded
    re1 <- usdm::exclude(subset,v1) # exclude the collinear variables that were identified in the previous step
    print(re1)
    finaldata_without_group_dimensions_colianearity = cbind(finaldata_without_group_dimensions_colianearity,re1)
  }
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
  chorddiag::chorddiag(sig_matrix_total,groupnamePadding = 30,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30,showTicks = FALSE)
  
  #--------ChordDiagram positive--------------------------------------
  sig_matrix_positive <-sig_matrix
  sig_matrix_positive[sig_matrix_positive <0] <- 0
  sig_matrix_positive[sig_matrix_positive < 0.6] <- 0
  sig_matrix_positive<-sig_matrix_positive*100
  chorddiag::chorddiag(sig_matrix_positive,groupnamePadding = 30,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30,showTicks = FALSE)
  
  #--------ChordDiagram negative--------------------------------------
  sig_matrix_negative <-sig_matrix
  sig_matrix_negative[sig_matrix_negative >0] <- 0
  sig_matrix_negative[sig_matrix_negative > -0.6] <- 0
  sig_matrix_negative<-sig_matrix_negative*100
  sig_matrix_negative<-abs(sig_matrix_negative)
  chorddiag::chorddiag(sig_matrix_negative,groupnamePadding = 30,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30,showTicks = FALSE, clickAction = "alert( d.source.index);")
  
  chorddiag::chorddiag(sig_matrix_negative,groupnamePadding = 30,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30,showTicks = FALSE,tooltipUnit = " %",precision = 4, 
clickAction = "alert( JSON.stringify(d));  
var lala = d.source.index; 
alert( 'http://212.101.173.35/getscatterplot/'+this.id+'/'+d.source.value);

var url = 'sample-url.php';
var params = 'lorem=ipsum&name=alpha';
var xhr = new XMLHttpRequest();
xhr.open('POST', url, true);

//Send the proper header information along with the request
xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

xhr.send(params);
")
 
#window.open( 'http://212.101.173.35/getscatterplot/'+this.id+'/'+d.source.value);
  
  
  #----------------------------------------------
  M<-cor(finaldata)
  dim(M)
  highlyCorrelated <- caret::findCorrelation(M, cutoff=(0.90),verbose = FALSE)
  important_metrics = M[-highlyCorrelated,-highlyCorrelated]
  dim(important_metrics)
  important_metrics<-abs(important_metrics)
  
  important_metrics[important_metrics ==1] <- 0
  important_metrics[important_metrics < 0.4] <- 0

  important_metrics[important_metrics > 0.9] <- 0  
  
  important_metrics<- important_metrics[-1:-35,-1:-35]
  chorddiag::chorddiag(important_metrics,groupnamePadding = 30,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30)
  #----------------------------------------------
  M<-cor(finaldata)
  dim(M)
 
  
  highlyCorrelated <- caret::findCorrelation(M, cutoff=(0.80),verbose = FALSE)
  
  important_metrics = M[-highlyCorrelated,-highlyCorrelated]
  dim(important_metrics)
  
 
  important_metrics[important_metrics < 0.3 & important_metrics > -0.3 ] <- 0
  
  important_metrics[important_metrics ==1] <- 0.0
  
  important_metrics[is.nan(important_metrics)] = 0
  
  row.names(important_metrics)
  colnames(important_metrics)
  chorddiag::chorddiag(important_metrics)
  important_metrics <- 300 * important_metrics
  
  chorddiag::chorddiag(important_metrics, groupnamePadding = 30,groupnameFontsize = 10,showZeroTooltips = FALSE,margin = 30)
  
  #----------------------------------------------
  output = psych::corr.test(finaldata)
  A = output$r    # matrix A here contains the correlation coefficients
  B = output$p   # matrix B here contains the corresponding p-values
  
  sig_matrix = ifelse(B < 0.05, A, 0)
  sig_matrix[sig_matrix=1] <- 0
  sig_matrix[sig_matrix < 0.2 & sig_matrix > -0.2] <- 0
  
  highlyCorrelated <- caret::findCorrelation(sig_matrix, cutoff=(0.95),verbose = FALSE)
  important_var=colnames(A[,-highlyCorrelated])
  
  important_metrics = A[-highlyCorrelated,-highlyCorrelated]
  
  dim(important_metrics)
  
  cl <- colors(distinct = TRUE)
  set.seed(15887) # to set random generator seed
  groupColors <- sample(cl, nrow(important_metrics))
  
  chorddiag::chorddiag(important_metrics,groupColors = groupColors, groupnamePadding = 50)
  chorddiag::chorddiag(important_metrics, groupnamePadding = 30)
  
  #----------------------------------------------
  sig_matrix = ifelse(B < 0.05, A, NA)
  
  sig_matrix[is.na(sig_matrix)] <- 0
  
  sig_matrix[sig_matrix=1] <- 0
  
  sig_matrix_na_rows <- sig_matrix[rowSums(is.na(sig_matrix)) == 0,]

  
  cl <- colors(distinct = TRUE)
  set.seed(15887) # to set random generator seed
  groupColors <- sample(cl, nrow(sig_matrix))
  
  chorddiag::chorddiag(sig_matrix,groupColors = groupColors, groupnamePadding = 50)
  
  unique_friendly_names <- unique(metrics_appendix$friendlyName)
  for(i in unique_friendly_names) {
    unique_row_friendly_name <- i
    a <- metrics_list[which(metrics_list$friendlyName== unique_row_friendly_name), ]
    print("------------")
    print(a$metric_number)
  }
  
  
  
  dimnames(titanic.mat ) <- list(Class = levels(titanic_tbl$Class),
                                 Survival = levels(titanic_tbl$Survived))
  
  
  
  m <- matrix(c(0,  5871, 8916, 2868,
                1951, 10048, 0, 6171,
                8010, 16145, 8090, 8045,
                1013,   990,  940, 0),
              byrow = TRUE,
              nrow = 4, ncol = 4)
  haircolors <- c("black", "blonde", "brown", "red")
  dimnames(m) <- list(have = haircolors,
                      prefer = haircolors)
  
  groupColors <- c("#000000", "#FFDD89", "#957244", "#F26223")
  mychord <- chorddiag::chorddiag(m, groupColors = groupColors, groupnamePadding = 20)
  
  
  rbPal <- colorRampPalette(c('red','blue'))
  groupColors <- rbPal(10)
  chorddiag::chorddiag(m, groupColors = groupColors, groupnamePadding = 20)
  
  mychord_to_retunr <- htmlwidgets::saveWidget(mychord, file = "mychord.html")
  return (mychord_to_retunr)
}