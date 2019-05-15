linear_regression_from_chord <- function(source_index,target_index,metrics_appendix) {
  
  
  dependent_var <- paste("m_",source_index+1,sep="")  
  independent_var <- paste("m_",target_index+1,sep="")

  dependent_metric_row = metrics_appendix[metrics_appendix$metric_number ==dependent_var , ] 
  dependent_metric_name = dependent_metric_row$metric_name
  
  independent_metric_row = metrics_appendix[metrics_appendix$metric_number ==independent_var , ] 
  independent_metric_name = independent_metric_row$metric_name  
  
  prometheus_url <- dependent_metric_row$prometheus
  start <- dependent_metric_row$start
  end <- dependent_metric_row$end
  step <- dependent_metric_row$step
  
  
  #print (dependent_var)
  #print (independent_var)
  #print (metrics_appendix)
  
  
  mydata1 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(dependent_metric_name),toString(dependent_metric_name),toString(dependent_metric_name),start,end,step)
  
  mydata2 <- convertPrometheusDataToTabularFormat(prometheus_url,toString(independent_metric_name),toString(independent_metric_name),toString(independent_metric_name),start,end,step)
  
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
  
  
  metricsCombination <-  scatterD3::scatterD3(x = xaxisd3, y = yaxisd3,xlab = independent_metric_name, ylab = dependent_metric_name, lines = data.frame(slope = myslope, intercept = myintercept),ellipses = TRUE, caption = list(title = paste("X-AXIS:  ",independent_metric_name, "Y-AXIS:  ", dependent_metric_name),subtitle = paste("METRICS CORRELATION: ", toString(capture.output(cor.test(xaxisd3, yaxisd3, method=c("pearson", "kendall", "spearman"))))),text =  paste("LINEAR MODEL INFORMATION:" , linearModString,sep="\n")))
  
  metricsCombination_to_return <- htmlwidgets::saveWidget(metricsCombination, file = "linear_regression.html")
  write.csv(finaldata, file = "finaldata.csv")
  return(metricsCombination_to_return)

  
#return (paste(source_index,target_index, sep=""))
  
}


