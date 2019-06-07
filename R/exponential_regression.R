exponential_regression <- function(prometheus_url,periods,step,metrics,enriched){
  
  step <- paste("&step=" ,step, sep="")
  
  metric1name = metrics[1]
  metric1friendlyName = metrics[1]
  metric1dimensions = stringr::str_extract(metrics[1], stringr::regex("\\{.*\\}"))
  
  metric2name =metrics[2]
  metric2friendlyName =metrics[2]
  metric2dimensions = stringr::str_extract(metrics[2], stringr::regex("\\{.*\\}"))
  
  datalist = list()
  
  for(i in 1:nrow(periods)) {
    #print(periods[i, "start"])
    start <- paste("&start=" ,periods[i, "start"], sep="")
    end <- paste("&end=" ,periods[i, "end"], sep="")
    #print(start)
    #print(end)
    mydata1 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(metric1name),toString(metric1friendlyName),toString(metric1dimensions),start,end,step)
    
    mydata2 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(metric2name),toString(metric2friendlyName),toString(metric2dimensions),start,end,step)
    
    finaldata <- merge(mydata1, mydata2, by = "timestamp")
    datalist[[i]] <-finaldata
  }
  
  big_data = do.call(rbind, datalist)
  
  #yaxisd3 <- colnames(big_data)[2]
  #xaxisd3 <- colnames(big_data)[3]
  
  yaxisd3 <- big_data[[colnames(big_data)[2]]]
  xaxisd3 <- big_data[[colnames(big_data)[3]]]
  
  xaxisd3 <- as.numeric(as.character(xaxisd3))
  yaxisd3 <- as.numeric(as.character(yaxisd3))
  nrow(big_data)
  
  linearMod <- lm(yaxisd3 ~ log(xaxisd3), data = big_data)  # build linear regression model on full data
  print(linearMod)
  summary(linearMod) 
  
  fit4 <- lm(log(yaxisd3)~xaxisd3)
  
  #generate range of 50 numbers starting from 30 and ending at 160
  xx <- seq(0,80, length=610)
  plot(xaxisd3,log(yaxisd3))
  lines(xx, predict(fit4, data.frame(x=xx)), col="red")
  
  
  
}