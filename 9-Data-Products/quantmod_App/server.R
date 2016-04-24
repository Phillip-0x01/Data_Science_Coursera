library(shiny)
library(quantmod)
options("getSymbols.warning4.0"=FALSE)

shinyServer(function(input, output) {
  
  TickerSymbol <- reactive({
    tryCatch({
      suppressWarnings(getSymbols(input$stock, from=input$dtRange[1], to=input$dtRange[2],
                                  auto.assign = FALSE))
    }, error = function(err) {
      return(NULL)
    })
  })
  
  output$distPlot <- renderPlot({
    taStr <- "addVo()"
            if (!is.null(input$trend)) {
               for (trend in input$trend) {
                 taStr<-paste(taStr, paste(";", trend))
              }}
            if (!is.null(input$volatility)) {
              for (volatility in input$volatility) {
                taStr<-paste(taStr, paste(";", volatility))
              }}
            if (!is.null(input$momentum)) {
              for (momentum in input$momentum) {
                taStr<-paste(taStr, paste(";", momentum))
              }}
            if (!is.null(input$volume)) {
              for (volume in input$volume) {
                taStr<-paste(taStr, paste(";", volume))
              }}
            
            if(!is.null(TickerSymbol())) {
              chartSeries(TickerSymbol(), name=input$stock, TA=taStr, theme=chartTheme("black"))
            }
          })
          
  output$dispPrint <- renderPrint({
    print(TickerSymbol())
  })
})