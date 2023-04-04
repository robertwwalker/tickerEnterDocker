library(shiny)
library(dplyr)
library(tidyquant)
library(plotly)
library(bslib)
library(thematic)
options(scipen=6)

# Define UI for dataset viewer app ----
ui <- fluidPage(theme = bs_theme(bootswatch = "superhero", 
                                 version = 5),
                
                # App title ----
                titlePanel("Tickers and Beta"),
                
                # Sidebar layout with input and output definitions ----
                sidebarLayout(
                  
                  # Sidebar panel for inputs ----
                  sidebarPanel(
                    
                    # Input: Text for providing a caption ----
                    # Note: Changes made to the caption in the textInput control
                    # are updated in the output area immediately as you type
                    textInput(inputId = "ticker",
                              label = "Ticker",
                              value = "F"),
                    submitButton("Update View", icon("refresh")),
                    h3(textOutput("caption2")),
                    plotlyOutput("ts_plot", height="500px")
                  ),
                  
                  # Main panel for displaying outputs ----
                  mainPanel(
                    
                    # Output: Formatted text for caption ----
                    h3(textOutput("caption")),
                    
                    # Output: Verbatim text for data summary ----
                    verbatimTextOutput("summary"),
                    plotlyOutput("main_plot", height="500px")
                  )
                )
)

# Define server logic to summarize and view selected dataset ----
server <- function(input, output) {
  thematic_shiny()
# Collect the data for the S&P 500
  DatG <- tq_get("^GSPC", from="2018-04-01", to="2023-04-01") |>
    tq_transmute(mutate_fun = monthlyReturn)
  names(DatG) <- c("date","SandP500")
  output$caption <- renderText({
    input$ticker
  })
  output$caption2 <- renderText({
    paste0("Time Series Plot: ",input$ticker, sep="")
  })
# Generate the regression result
  output$summary <- renderPrint({
    Data <- tq_get(c(input$ticker), from="2018-04-01", to="2023-04-01") |>
      tq_transmute(mutate_fun = monthlyReturn) |> 
      left_join(DatG) |> 
      filter(date > as.Date("2018-04-01"))
    res <- lm(monthly.returns~SandP500, data=Data)
    summary(res)
  })
  
# Generate the plotly with renderPlotly
  output$main_plot <- renderPlotly({
    Data <- tq_get(c(input$ticker), from="2018-04-01", to="2023-04-01") |>
      tq_transmute(mutate_fun = monthlyReturn) |> 
      left_join(DatG) |> 
      filter(date > as.Date("2018-04-01"))
    df <- data.frame(tit=paste0("CAPM: ",input$ticker, sep=""))
    ggplot(Data,
           aes(x=SandP500, y=monthly.returns)) + geom_point() + geom_smooth(method="lm") + labs(title=df$tit, x="S&P 500 Monthly Returns", y=input$ticker)
  })
  output$ts_plot <- renderPlotly({
    Data <- tq_get(c(input$ticker), from="2018-04-01", to="2023-04-01") |>
      plot_ly(type = 'scatter', mode = 'lines') |>
      add_trace(x = ~date, y = ~adjusted, fill = 'tozeroy', color = I("steelblue"), name = input$ticker) |>
      layout(showlegend = F, yaxis = list(title = 'Adjusted Closing Price'))
  })
}

# Create Shiny app ----
shinyApp(ui, server)