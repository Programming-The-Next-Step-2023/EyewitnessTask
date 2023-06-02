library(shiny)
library(shinythemes)

ui <- fluidPage(
  theme = shinytheme("cyborg"),
  h2("Hello!"),
  h4("You are about to watch a video and then answer some questions."),
  p("Please watch the video only once and then click the arrow."),
  
  # Play video
  conditionalPanel(
    condition = "input.VideoComplete == 0",
    uiOutput("crimevideo"),
    actionButton("VideoComplete", "➡️")
  ),
  
  # Text entry for description
  conditionalPanel(
    condition = "input.VideoComplete > 0",
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
          label = "Description:",
          rows = 4,
          placeholder = "Enter your description here"
        )
      ),
      # DescriptionComplete button
      column(
        width = 2,
        actionButton("DescriptionComplete", "➡️")
      )
    )
  ),
  
  # Distractor task
  conditionalPanel(
    condition = "input.DescriptionComplete > 0",
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
    actionButton("DistractorTaskComplete", "➡️")
  ),
  
  # Lineup images 
  conditionalPanel(
    condition = "input.DistractorTaskComplete > 0 && input.LineupSelectionComplete == 0",
    fluidRow(
      column(
        width = 12,
        h2(
          "Recall the video of the bag snatching that you watched a few minutes ago.
        The police have contacted you to identify the man who stole the bag.
        You will be presented with a lineup and asked to type the number of the person you saw.
        The person you saw may or may not be present.
        If you believe that they are not present, type 0.
        Once you have made your decision, click the blue button to continue."
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        uiOutput("LineupImages")
      )
    ),
    fluidRow(
      column(
        width = 12,
        actionButton("LineupSelectionComplete", "➡️")
      )
    )
  ),
  
    
    # Confidence rating
    conditionalPanel(
      condition = "input.LineupSelectionComplete > 0",
      p("How confident are you that you made the correct decision?"),
      # Scale input
      sliderInput(
        "scaleInput",
        "Scale",
        min = 1,
        max = 100,
        value = 50
      ),
      actionButton("SubmitConfidenceRating", "➡️"),
      
      # Feedback
      conditionalPanel(
        condition = "input.SubmitConfidenceRating > 0",
        "Feedback goes here..."
      )
    )
  )
)

server <- function(input, output, session) {
  addResourcePath(prefix = "stimuli", directoryPath = "C:/Users/veerl/OneDrive/Documents/UvA/TheNextStep/IWitness/stimuli")
  addResourcePath(prefix = "flags", directoryPath = "C:/Users/veerl/OneDrive/Documents/UvA/TheNextStep/IWitness/flags")
  addResourcePath(prefix = "lineups", directoryPath = "C:/Users/veerl/OneDrive/Documents/UvA/TheNextStep/IWitness/lineups")
  
  # Define the video options
  videoOptions <- c("stimuli/crimevideo1.mp4", "stimuli/crimevideo2.mp4")
  
  # Randomly select a video from the options
  selectedVideo <- reactive({
    sample(videoOptions, 1)
  })
  
  # Set the selected video as the source for the video player
  output$crimevideo <- renderUI({
    tags$video(
      id = "crimevideo",
      src = selectedVideo(),
      type = "video/mp4",
      autoplay = FALSE,
      controls = TRUE
    )
  })
  
  # Determine the lineup based on the selected video
  lineupOptions <- reactive({
    if (selectedVideo() == "stimuli/crimevideo1.mp4") {
      if (runif(1) > 0.5) {
        c("lineups/LineupP1TA.jpg")
      } else {
        c("lineups/LineupP1TP.jpg")
      }
    } else {
      if (runif(1) > 0.5) {
        c("lineups/LineupP2TA.jpg")
      } else {
        c("lineups/LineupP2TP.jpg")
      }
    }
  })
  
  # Render the lineup images
  output$LineupImages <- renderUI({
    lineupPaths <- lineupOptions()
    div(class = "lineup-images",
        lapply(lineupPaths, function(path) {
          fluidRow(
            column(
              width = 3,
              tags$img(src = path, width = "600px")
            )
          )
        })
    )
  })
}

runApp <- function() {
  shinyApp(ui = ui, server = server)
}

runApp()
