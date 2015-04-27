library(shiny)


shinyUI(pageWithSidebar(
    headerPanel("Viewing Ping Data"),
    sidebarPanel(
      sliderInput("range", 
                  label = "Range of interest:",
                  min = 0, max = 1400, value = c(0, 1400)),
      tags$div(class = "header", checked = NA,
               tags$p("Move the range bars to restrict the Message #"),
               tags$p("The data was generated on a Linux machine running 'ping 8.8.8.8 > ping2.txt' in a command prompt."),
               tags$p("Ping sends a message to a server, the server sends the message back, and ping records how long it took in milliseconds.  In this case, the server is 8.8.8.8, which is Google DNS server to translate domain names to IP Addresses.  So, if the response times are slow, then your internet access in general is slow.  The red dots is anything more than 1 standard deviation from the mean."),
               tags$a(href = "http://en.wikipedia.org/wiki/Ping_(networking_utility)", "More information about ping can be found on wikipedia")
      )
    ),
    mainPanel(
      plotOutput("distPlot"),
      textOutput("summary"),
      plotOutput("histPlot")
    )
))

#