library(shiny)

# Define UI for application demonstrates R package quantmod graph capabilities
shinyUI(pageWithSidebar(
    headerPanel(""),
    sidebarPanel(
      
      textInput("stock", "Enter a stock symbol below", value = "AAPL", width = "50%"),
      p(em("(or click ", a("here", href="http://eoddata.com/symbols.aspx", target="_blank"), "for a complete list of symbols)")),
      br(),
      br(),
      dateRangeInput("dtRange", "Date Range", start = Sys.Date()-90, end = NULL, min = NULL, max = NULL, format = "yyyy-mm-dd", startview = "month", weekstart = 0, language = "en", separator = " to ", width = NULL),
      
      #hr(),
      br(),
    
      h4("Add Technical Analysis Overlay(s)"),
     
       checkboxGroupInput("trend", "Trend:",
                          c("Directional Movement Index" = "addADX()",
                            "Double Expotential Moving Average" = "addDEMA()",
                            "Expotential Moving Average" = "addEMA()",
                            "Expotential Volume Weighted Moving Average" = "addEVWMA()",
                            "Moving Average Convergence Divergence" = "addMACD()",
                            "Parabolic Stop and Reversal Indicator" = "addSAR()",
                            "Simple Moving Average" = "addSMA()",
                            "Weighted Moving Average" = "addWMA()",
                            "ZLEMA" = "addZLEMA()")),

        checkboxGroupInput("volatility", "Volatility:",             
                          c("Average True Range" = "addATR()",
                            "Bollenger Bands" = "addBBands()",
                            "Price Envelope" = "addEnvelope()"
                          )),
      
        checkboxGroupInput("momentum", "Momentum:",           
                          c("Chande Momentum Oscillator" = "addCMO()",
                            "Commodity Channel Index" = "addCCI()",
                            "De-trended Price Oscillator" = "addDPO()",
                            "Momentum" = "addMomentum()",
                            "Rate of Change" = "addROC()",
                            "Relative Strength Index" = "addRSI()",
                            "Stochastic Momemtum Indicator" = "addSMI()",
                            "Williams %R" = "addWPR()"
                          )),

        checkboxGroupInput("volume", "Volume:",           
                          c("Chaiken Money Flow" = "addCMF()")
                          )
      ),
    
    # Show the demonstration plot
    mainPanel(plotOutput("distPlot", height="885px") #,textOutput("dispPrint")
    )
  ))
