library(shiny)
library(shinythemes)

ui <- navbarPage(
  title = "IWITNESS",
  theme = shinytheme("cyborg"),
  id = "nav",
  tabPanel(
    "Video",
    h2("Hello!"),
    h4("You are about to watch a video and then answer some questions."),
    p("Please watch the video only once and then move to the next panel."),
    # Play video
    uiOutput("crimevideo")
  ),
  
  tabPanel(
    "Description",
    h2("Description"),
    conditionalPanel(
      condition = "input$VideoComplete > 0",
      fluidRow(
        column(
          width = 8,
          p("Using a few words, please describe the perpetrator (the one who committed the crime) of the video you watched.")
        )
      ),
      fluidRow(
        column(
          width = 8,
          textAreaInput(
            "descriptionEntry",
            label = " ",
            rows = 4,
            placeholder = "Enter your description here"
          )
        )
      )
    )
  ),
  tabPanel(
    "Flag",
    conditionalPanel(
      condition = "input$DescriptionComplete > 0",
      id = "distractorTask",
      h2("Name the country of these flags below"),
      fluidRow(
        column(
          width = 4,
          tags$img(src = "flags/SouthAfrica.png", width = "300px"),
          textInput("textEntry1", "Flag 1")
        ),
        column(
          width = 4,
          tags$img(src = "flags/Brazil.png", width = "300px"),
          textInput("textEntry2", "Flag 2")
        ),
        column(
          width = 4,
          tags$img(src = "flags/Ghana.jpg", width = "300px"),
          textInput("textEntry3", "Flag 3")
        ),
        column(
          width = 4,
          tags$img(src = "flags/Netherlands.png", width = "300px"),
          textInput("textEntry4", "Flag 4")
        ),
        column(
          width = 4,
          tags$img(src = "flags/Ukraine.jpg", width = "300px"),
          textInput("textEntry5", "Flag 5")
        ),
        column(
          width = 4,
          tags$img(src = "flags/Egypt.jpg", width = "300px"),
          textInput("textEntry6", "Flag 6")
        )
      ),
      verbatimTextOutput("flagFeedback")
    )
  ),
  
  tabPanel(
    "Selection",
    h2("Lineup"),
    uiOutput("lineupSection"),
  ),
  
  tabPanel(
    "RatingTask",
    h2("Confidence"),
    fluidRow(
      column(
        width = 8,
        p("Please rate your confidence in your decision:")
      )
    ),
    fluidRow(
      column(
        width = 4,
        sliderInput("confidenceSlider", "Confidence:", min = 0, max = 100, value = 50)
      )
    )
  ),
  
  tabPanel(
    "Feedback",
    uiOutput("feedbackSection")
  )
)

server <- function(input, output, session) {

  # Define the video options
  videoOptions <- c("stimuli/crimevideo1.mp4", "stimuli/crimevideo2.mp4")
  
  # Randomly select a video from the options
  selectedVideo <- reactiveVal(sample(videoOptions, 1))
  
  # Set the selected video as the source for the video player
  output$crimevideo <- renderUI({
    tags$video(
      id = "crimevideo",
      src = selectedVideo(),
      type = "video/mp4",
      autoplay = FALSE,
      controls = TRUE,
      width = "800px", 
      height = "600px" 
    )
  })
  
  # Observer to update video source when VideoComplete button is clicked
  observeEvent(input$VideoComplete, {
    selectedVideo <- sample(videoOptions, 1)
  })
  

  output$flagFeedback <- renderPrint({
    enteredFlags <- c(input$textEntry1, input$textEntry2, input$textEntry3,
                      input$textEntry4, input$textEntry5, input$textEntry6)
    
    if (all(nchar(enteredFlags) > 0)) {
      correctFlags <- c("South Africa", "Brazil", "Ghana", "Netherlands", "Ukraine", "Egypt")
      
      if (identical(enteredFlags, correctFlags)) {
        "Congratulations! You got all the flag names correct!"
      } else {
        "Oops! Please check your answers and try again."
      }
    }
  })
  
  
  # Determine the lineup based on the selected video
  lineupOptions <- reactive({
    if (selectedVideo() == "stimuli/crimevideo1.mp4") {
      if (runif(1) > 0.5) {
        c("lineups/LineupP1TA.jpg")
      } else {
        c("lineups/LineupP1TP.jpg")
      }
    } else if (selectedVideo() == "stimuli/crimevideo2.mp4") {
      if (runif(1) > 0.5) {
        c("lineups/LineupP2TA.jpg")
      } else {
        c("lineups/LineupP2TP.jpg")
      }
    } else {
      character(0)  # Return an empty character vector if the selected video is not recognized
    }
  })
  
  # Show lineup section
  output$lineupSection <- renderUI({
    tagList(
      HTML("Recall the video of the bag snatching that you watched a few minutes ago.<br>
      The police have contacted you to identify the man who stole the bag.<br>
      State the number of the person you saw.<br>
      The person you saw may or may not be present.<br>
      If you do not think they are present, respond with 0."),
      
      fluidRow(
        column(
          width = 6,
          tags$img(src = lineupOptions()[1], width = "800px"),
          textInput("lineupSelection", "Enter your response")
        )
      )
    )
  } )
  
  
  # Show feedback section
  output$feedbackSection <- renderUI({
    if (lineupOptions()[1] == "lineups/LineupP1TA.jpg" || lineupOptions()[1] == "lineups/LineupP2TA.jpg") {
      if (input$lineupSelection == 0) {
        tagList(
          h4("You are correct! The innocent suspect is less likely to be found guilty.")
        )
      } else {
        tagList(
          h4("Unfortunately, you selected an innocent person. The perpetrator was not in the lineup.")
        )
      }
    } else if (lineupOptions()[1] == "lineups/LineupP1TP.jpg") {
      if (input$lineupSelection == 8) {
        tagList(
          h4("You are correct! Suspect number 8 committed the crime.")
        )
      } else {
        tagList(
          h4("Unfortunately, you chose the wrong option! Suspect 8 committed the crime.")
        )
      }
    } else if (lineupOptions()[1] == "lineups/LineupP2TP.jpg") {
      if (input$lineupSelection == 7) {
        tagList(
          h4("You are correct! Suspect number 7 committed the crime.")
        )
      } else {
        tagList(
          h4("Unfortunately, you chose the wrong option! Suspect 7 committed the crime.")
        )
      }
    } else {
      tagList(
        h4("Feedback not available for the selected image")
      )
    }
  })
}

runApp <- function() {
  shinyApp(ui = ui, server = server)
}

runApp()
