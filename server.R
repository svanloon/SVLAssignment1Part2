library(shiny)
library(stringr)
library(dplyr)

shinyServer(function(input, output) {

    getFilteredData <- function () {
      convertPingDataToDataFrame <- function(fileName) {
        pattern <- "\\d+ bytes from (\\d+.\\d+.\\d+.\\d+): icmp_seq=(\\d+) ttl=\\d+ time=(\\d+.\\d+) ms"
        labels <- c("destination", "icmp_seq", "time")
        
        rawData <- readLines(fileName)
        # skip header row
        rawData <- rawData[2:length(rawData)]
        
        parseRow <- function(rawRow) {
          parsedRow <- str_match(rawRow, pattern)
          row <- parsedRow[2:length(parsedRow)]
          #print(row)
          matrix(row, ncol=length(labels), dimnames=list(c("asdf"), labels))
        }
        df <- data.frame(t(sapply(rawData, FUN=parseRow)))
        names(df) <- labels
        # remove incomplete data
        df <- df[complete.cases(df) & !is.na(df$time), ]
        
        # put into table
        # make time and icmp_seq numeric
        # order by icmp_seq because package can come back out of order
        tbl_df(df) %>% 
          mutate(time=as.numeric(as.character(time)) , icmp_seq=as.numeric(as.character(icmp_seq))) %>% 
          arrange(icmp_seq)
        
        
      }
      data <- convertPingDataToDataFrame("ping2.txt")
      range <- data.frame(lower=min(input$range[1]), upper=max(input$range[2]))
      filteredData <- data %>% filter(icmp_seq > range$lower & icmp_seq < range$upper)
    }

    output$distPlot <- renderPlot({

      filteredData <- getFilteredData()
      colorize <- function(x, xs) {
        s <- summary(filteredData$time)
        if(x < s["1st Qu."]) {
          "blue"
        } else if(x > s["3rd Qu."]) {
          "red"
        } else {
          #s["Median"]
          "black"
        }
      }
      colors <- sapply(filteredData$time, FUN=colorize, filteredData$time)
      
      
      plot(filteredData$icmp_seq, filteredData$time, type="p", xlab="Message # (aka icmp_seq)", ylab="Time (ms)", main="Ping response times", col=colors)
    })
    output$histPlot <- renderPlot({
        filteredData <- getFilteredData()
        hist(filteredData$time, xlab="Time (ms)", main="Histogram of Response Time")
    })
    output$summary <- renderText({
      filteredData <- getFilteredData()
      paste("The average response time of the data shown is: ", round(mean(filteredData$time)), " ms and max time: ", round(max(filteredData$time)), " ms")
    })
  
})
