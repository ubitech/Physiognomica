test <- function(prometheus_url,periods,step,metrics,enriched) {
  
  #for(i in 1:nrow( periods )) {
  # print(periods[i, "start"])
  #  print('--------------------------------')
  #/}
  
  metrics_list = data.frame(name=metrics,friendlyName=metrics,dimensions = stringr::str_extract(metrics, stringr::regex("\\{.*\\}")))
  print(metrics_list)
  
  ibody <- shiny::tags$div(shiny::tags$h3("This is demo in madrid test analytics results page"))
  
  page_body <- shiny::tags$html(
    shiny::tags$body(
      ibody
    )
  ) 
  htmltools::save_html(page_body,file = "test.html")
  
}
