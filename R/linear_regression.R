# This is an function named 'combinePrometheusMetrics'
# which has as output a visualization of two prometheus metrics
#prometheus_url = "http://212.101.173.70:9090/api/v1/query?query="
#prometheus_url = "http://212.101.173.70:9090/api/v1/query_range?query="
#start = "2018-09-27T10:10:30.781Z"
#end = "2018-09-27T20:11:00.781Z"
#step = "10m"
#period = "[1m]"
#metric1 = "netdata:lambdaapp:traefik:lambdacoreapp_cgroup_cpu_per_core_percent_average"
#metric2 = "netdata:lambdaapp:traefik:lambdaproxy_disk_io_kilobytes_persec_average{dimension=\"writes\"}"
#profiling_type = "Resource Efficiency"
#fisiognomica::combinePrometheusMetrics(prometheus_url,start,stop,step,metric1,metric2,profiling_type)
linear_regression <- function(prometheus_url,start,end,step,metrics,enriched) {

  start <- paste("&start=" ,start, sep="")
  end <- paste("&end=" ,end, sep="")
  step <- paste("&step=" ,step, sep="")
  
  
  metric1name = metrics[1]
  metric1friendlyName = metrics[1]
  metric1dimensions = stringr::str_extract(metrics[1], stringr::regex("\\{.*\\}"))
  
  metric2name =metrics[2]
  metric2friendlyName =metrics[2]
  metric2dimensions = stringr::str_extract(metrics[2], stringr::regex("\\{.*\\}"))

 mydata1 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(metric1name),toString(metric1friendlyName),toString(metric1dimensions),start,end,step)
 
 mydata2 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(metric2name),toString(metric2friendlyName),toString(metric2dimensions),start,end,step)
 
 finaldata <- merge(mydata1, mydata2, by = "timestamp")
 
 yaxisd3 <- finaldata[[colnames(mydata1)[2]]]
 xaxisd3 <- finaldata[[colnames(mydata2)[2]]]
 
 xaxisd3 <- as.numeric(as.character(xaxisd3))
 yaxisd3 <- as.numeric(as.character(yaxisd3))
 
 linearMod <- lm(yaxisd3 ~ xaxisd3, data = finaldata)  # build linear regression model on full data
 print(linearMod)
 summary(linearMod) 
 
 
 cor(xaxisd3, yaxisd3)
 cor.test(xaxisd3, yaxisd3, method=c("pearson", "kendall", "spearman"))

 linearModString <- toString(capture.output(summary(linearMod)))
 
 #basicplot <- ggplotRegression(linearMod)
 
 myslope <-coef(linearMod)["xaxisd3"]
 myintercept <- coef(linearMod)["(Intercept)"]
 
 
 metricsCombination <-  scatterD3::scatterD3(x = xaxisd3, y = yaxisd3,xlab = metric2friendlyName, ylab = metric1friendlyName, lines = data.frame(slope = myslope, intercept = myintercept),ellipses = TRUE, caption = list(title = paste("X-AXIS:  ",metric2friendlyName, "Y-AXIS:  ", metric1friendlyName),subtitle = paste("METRICS CORRELATION: ", toString(capture.output(cor.test(xaxisd3, yaxisd3, method=c("pearson", "kendall", "spearman"))))),text =  paste("LINEAR MODEL INFORMATION:" , linearModString,sep="\n")))
 
 metricsCombination_to_return <- htmlwidgets::saveWidget(metricsCombination, file = "metricsCombination.html")
 write.csv(finaldata, file = "finaldata.csv")
 return(metricsCombination_to_return)
 
 #label<-paste("Full Axis Names are as follows:\n X-AXIS:\n",metric1friendlyName, "\n Y-AXIS:\n", metric2friendlyName, sep="\n" ) 
 #basicplot <- ggplot2::qplot(x=finaldata[[colnames(mydata1)[2]]],
 #                       y=finaldata[[colnames(mydata2)[2]]],
 #                       data=finaldata,
 #                       main=profiling_type,
 #                       xlab=substr(x_axis_name, 1, 30),
 #                       ylab=substr(y_axis_name, 1, 30),group=1)+
 # ggplot2::geom_line(colour="steelblue") +
 # ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1))

 
 #p2 <- cowplot::add_sub(basicplot, label, x = 0.5, y = 0.5, hjust = 0.5, vjust = 0.5,
 #        vpadding = grid::unit(1, "lines"), fontfamily = "", fontface = "plain",
 #        colour = "blue", size = 6, angle = 0, lineheight = 0.9)
 #basicplot<-cowplot::ggdraw(p2)
 
 # ggsave(file="test.svg", plot=basicplot, width=10, height=8)
 #fd2 <- finaldata
 #fd2$timestamp <- NULL
 #d3page <- r2d3::r2d3(data=fd2, options=c(25,50,-50,0,colnames(fd2)[1],colnames(fd2)[2],label),script = "R/linechart.js")
 #d3page1<- r2d3::save_d3_html(d3page, file = "lala.html")
 #XML::saveXML(d3page, file="lala.html", compression=0, indent=T)
 
}

ggplotRegression <- function (fit) {
  
  require(ggplot2)
  
  ggplot2::ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                       "Intercept =",signif(fit$coef[[1]],5 ),
                       " Slope =",signif(fit$coef[[2]], 5),
                       " P =",signif(summary(fit)$coef[2,4], 5)))
}

combinePrometheusPlots <- function(dataset1,dataset2,dataset3,x_axis_name,y_axis_name, description) {
  
  #dataset1$xvariable=as.numeric(levels(dataset1[[colnames(dataset1)[2]]]))[dataset1[[colnames(dataset1)[2]]]]
  
  #dataset1$yvariable=as.numeric(levels(dataset1[[colnames(dataset1)[3]]]))[dataset1[[colnames(dataset1)[3]]]]
  
  #dataset2$xvariable=as.numeric(levels(dataset2[[colnames(dataset2)[2]]]))[dataset2[[colnames(dataset2)[2]]]]
  
  #dataset2$yvariable=as.numeric(levels(dataset2[[colnames(dataset2)[3]]]))[dataset2[[colnames(dataset2)[3]]]]
  
  basicplot <- ggplot2::qplot(x=dataset1[[colnames(dataset1)[2]]],
                              y=dataset1[[colnames(dataset1)[3]]],
                              data=dataset1, size=I(0.6),
                              main="Combound Resource Efficiency Diagram",
                              xlab=substr(x_axis_name, 1, 30),
                              ylab=substr(y_axis_name, 1, 30),group=1)+
    ggplot2::geom_line(colour="steelblue") +
    ggplot2::geom_line(data=dataset2, ggplot2::aes(x =dataset2[[colnames(dataset2)[2]]], y=dataset2[[colnames(dataset2)[3]]]), color = "red") +
    ggplot2::geom_line(data=dataset3, ggplot2::aes(x =dataset3[[colnames(dataset3)[2]]], y=dataset3[[colnames(dataset3)[3]]]), color = "green") +
    #ggplot2::scale_x_continuous(breaks = scales::pretty_breaks()) +
    #ggplot2::scale_y_continuous(breaks = scales::pretty_breaks()) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1))
    
  
  p2 <- cowplot::add_sub(basicplot, description, x = 0.5, y = 0.5, hjust = 0.5, vjust = 0.5,
                         vpadding = grid::unit(1, "lines"), fontfamily = "", fontface = "plain",
                         colour = "blue", size = 6, angle = 0, lineheight = 0.9)
  basicplot<-cowplot::ggdraw(p2)
  
  return (basicplot)
}

convertPrometheusDataToTabularFormat <- function(prometheus_url,metric_name,metric_friendlyName,dimensions,start,end,step) {

    empty_matrix <-matrix(, nrow = 0, ncol = 0)
  print(paste("execute convertPrometheusDataToTabularFormat for metric ",metric_name, sep=""))
  
  prometheus_url_query_range <- paste(prometheus_url , "/api/v1/query_range?query=", sep="")
  print(paste(prometheus_url_query_range , metric_name, start,end,step, sep=""))
  result1 <-  httr::GET(paste(prometheus_url_query_range , metric_name, start,end,step, sep=""))

  data1 <-httr::content(result1)
  print ("data1")
  print (data1)
  if (data1=="400 Bad Request"){return (empty_matrix)}
  
  #metric_name1 <-data1$data$result[[1]]$metric$`__name__`
  #metric_name1 <-gsub(":", "_", metric_name1)
  if(length(data1$data$result)==0){
    print(paste("No datapoints found for ",metric_name, sep=""))
    return (empty_matrix)
  }
  values1 <- data1$data$result[[1]]$values
  if (is.null(values1)) {
    print("some null values here")
    return (empty_matrix)
  }else{
      print("i got the values")
      mydata1 <- matrix(unlist(values1),  ncol = 2, byrow = TRUE)
      #colnames(mydata1) <- c("timestamp", paste(metric_friendlyName , dimensions, sep=""))
      colnames(mydata1) <- c("timestamp", paste(metric_friendlyName , "", sep=""))
      #print(mydata1)
      return(mydata1)
    }
  
 
}

convertPrometheusDataToTabularFormatWithoutFriendlynames <- function(prometheus_url,metric_name,metric_friendlyName,dimensions,start,end,step) {
  
  empty_matrix <-matrix(, nrow = 0, ncol = 0)
  print(paste("execute convertPrometheusDataToTabularFormat for metric ",metric_name, sep=""))
  
  prometheus_url_query_range <- paste(prometheus_url , "/api/v1/query_range?query=", sep="")
  print(paste(prometheus_url_query_range , metric_name, start,end,step, sep=""))
  result1 <-  httr::GET(paste(prometheus_url_query_range , metric_name, start,end,step, sep=""))
  
  data1 <-httr::content(result1)
  print ("data1")
  print (data1)
  if (data1=="400 Bad Request"){return (empty_matrix)}
  
  #metric_name1 <-data1$data$result[[1]]$metric$`__name__`
  #metric_name1 <-gsub(":", "_", metric_name1)
  if(length(data1$data$result)==0){
    print(paste("No datapoints found for ",metric_name, sep=""))
    return (empty_matrix)
  }
  values1 <- data1$data$result[[1]]$values
  if (is.null(values1)) {
    print("some null values here")
    return (empty_matrix)
  }else{
    print("i got the values")
    mydata1 <- matrix(unlist(values1),  ncol = 2, byrow = TRUE)
    #colnames(mydata1) <- c("timestamp", paste(metric_friendlyName , dimensions, sep=""))
    colnames(mydata1) <- c("timestamp", metric_friendlyName)
    #print(mydata1)
    return(mydata1)
  }
  
  
}
#prometheous_url
#start
#end
#step
#metrics_appendix
#m1 <-19
#m2 <-43
#profiling_type <- "Resource Efficiency"
#return_type <- "plot"
combinePrometheusMetrics_chained_with_correlogram <- function(prometheus_url,start,end,step,metrics_appendix,m1,m2,profiling_type,return_type) {
  print("test combinePrometheusMetrics")
  if (typeof(metrics_appendix)!='list'){
    metrics_appendix <- read.csv(file="metrics_appendix.csv", header=TRUE, sep=",")
  }
  metric1 <-metrics_appendix[m1,]
  #metric1 <-toString(metric1$name)
  
  metric2 <-metrics_appendix[m2,]
  #metric2 <-toString(metric2$name)
  Physiognomica::combinePrometheusMetrics(prometheus_url,start,end,step,metric1,metric2,"Resource Efficiency","plot")
  
}

test_combinePrometheusPlots<- function() {
  print("test combinePrometheusPlots")
  #metric1 contain name
  m1_fm<-"Packets (net_packets.eth0){chart='net_packets.ens3',dimension='received',family='ens3'"
  m2_fm<-"Available RAM for applications (mem.available){chart='mem.available'"
  ############################################
  #Execute for streessAppC1
  ############################################
  sut1 <- "cpu: 1 ram: 2GB IP: 212.101.173.10"
  metrics_appendix <- read.csv(file="metrics_appendix.csv", header=TRUE, sep=",")
  metric1 <- metrics_appendix[which(grepl(m1_fm, metrics_appendix$friendlyName_with_dimensions, fixed=TRUE)), ]
  metric2 <- metrics_appendix[which(grepl(m2_fm, metrics_appendix$friendlyName_with_dimensions, fixed=TRUE)), ]
  
  dataset1 <-Physiognomica::combinePrometheusMetrics(prometheous_url,start,end,step,metric1,metric2,"Resource Efficiency","dataset")
  nrow(dataset1)
  
  ############################################
  #Execute for streessAppC2
  ############################################
  sut2 <- " cpu: 2 ram: 4GB IP: 212.101.173.24"
  metrics_appendix <- read.csv(file="metrics_appendix.csv", header=TRUE, sep=",")
  metric3 <- metrics_appendix[which(grepl(m1_fm, metrics_appendix$friendlyName_with_dimensions, fixed=TRUE)), ]
  metric4 <- metrics_appendix[which(grepl(m2_fm, metrics_appendix$friendlyName_with_dimensions, fixed=TRUE)), ]
  
  dataset2 <-Physiognomica::combinePrometheusMetrics(prometheous_url,start,end,step,metric3,metric4,"Resource Efficiency","dataset")
  nrow(dataset2)
  
  
  ############################################
  #Execute for streessAppC3
  ############################################
  sut3 <- "cpu: 4 ram: 8GB IP: 212.101.173.41"
  metrics_appendix <- read.csv(file="metrics_appendix.csv", header=TRUE, sep=",")
  metric5 <- metrics_appendix[which(grepl(m1_fm, metrics_appendix$friendlyName_with_dimensions, fixed=TRUE)), ]
  metric6 <- metrics_appendix[which(grepl(m2_fm, metrics_appendix$friendlyName_with_dimensions, fixed=TRUE)), ]
  
  dataset3 <-Physiognomica::combinePrometheusMetrics(prometheous_url,start,end,step,metric5,metric6,"Resource Efficiency","dataset")
  nrow(dataset3)
  
  
  label<-paste("Blue line represents SUT:\n ",sut1,
               "\nRed line represents SUT:\n ",sut2,
               "\nGreen line represents SUT:\n ",sut3,
               "\nFull Axis Names are as follows:\n X-axis:\n",m1_fm, "\n Y-axis:\n", m2_fm)
  Physiognomica::combinePrometheusPlots(dataset1,dataset2,dataset3,m1_fm,m2_fm, label)
}