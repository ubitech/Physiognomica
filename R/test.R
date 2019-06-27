test <- function(prometheus_url,periods,step,metrics,enriched) {
  
  for(i in 1:nrow( periods )) {
   print(periods[i, "start"])
    print('--------------------------------')
  }
  
  metrics_list = data.frame(name=metrics,friendlyName=metrics,dimensions = stringr::str_extract(metrics, stringr::regex("\\{.*\\}")))
  print(metrics_list)
  print('i did a small change')
  

  return (periods)
  
}