library(testthat)
library(shiny)

# Function to test: Video selection
videoSelectionTest <- function() {
  # Create a Shiny app object
  app <- runApp()
  
  # Get the initial selected video
  video <- app$selectedVideo()
  
  # Click the VideoComplete button
  app$session$enqueueInput("VideoComplete")
  app$session$runApp(app)
  
  # Expect that the video has changed
  expect_not_equal(app$selectedVideo(), video)
}

# Function to test: Flag feedback
flagFeedbackTest <- function() {
  # Create a Shiny app object
  app <- runApp()
  
  # Enter correct flag names
  app$input$textEntry1 <- "South Africa"
  app$input$textEntry2 <- "Brazil"
  app$input$textEntry3 <- "Ghana"
  app$input$textEntry4 <- "Netherlands"
  app$input$textEntry5 <- "Ukraine"
  app$input$textEntry6 <- "Egypt"
  
  # Get the flag feedback
  feedback <- app$output$flagFeedback()$print
  
  # Expect that the feedback is correct
  expect_equal(feedback, "Congratulations! You got all the flag names correct!")
}

# Function to test: runApp()
runAppTest <- function() {
  # Call the runApp function
  app <- runApp()
  
  # Expect that the app object is created
  expect_silent(app)
  
  # Expect that the app object contains the expected UI and server components
  expect_true("ui" %in% names(app))
  expect_true("server" %in% names(app))
}

# Run the tests
test_that("Video selection works correctly", {
  videoSelectionTest()
})

test_that("Flag feedback is displayed correctly", {
  flagFeedbackTest()
})

test_that("runApp function creates the app object", {
  runAppTest()
})
