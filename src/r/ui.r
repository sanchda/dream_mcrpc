library(shiny)

# Define UI, based loosely on one of Shiny's templates
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Dave's simple SVM lab"),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
    
      # Which combination of datasets to use?
      radioButtons("sets", "Select datasets:",
                 c("Demographics",
                   "Labs",
                   "Genes",
                   "demo + lab",
                   "demo + gene",
                   "lab + gene",
                   "all")),
      
      # For visualization, which components of PCA to see?
      sliderInput("pca1",
                  "First Principal Component (visual only):",
                  min = 1,
                  max = 15,
                  value = 1),
      sliderInput("pca2",
                  "Second Principal Component (visual only):",
                  min = 1,
                  max = 15,
                  value = 2),
      
      # Select which kernel to use
      radioButtons("kernel", "Select SVM kernel:",
                   c("Linear (none)" = "linear",
                     "RBF" = "radial",
                     "Polynomial" = "polynomial",
                     "Sigmoid" = "sigmoid")),
    
      # Optional parameters for each kernel
      conditionalPanel( "input.kernel == 'radial'",
                        numericInput("gamma", "gamma", value=0.01)      
      ),
      
      conditionalPanel( "input.kernel == 'polynomial'",
                        numericInput("gamma", "gamma:", value=0.01),
                        numericInput("coef0", "coef0:", value=0),
                        sliderInput("deg", "degree:", min=1, max=6, value=2)
      ),
      conditionalPanel( "input.kernel == 'sigmoid'",
                        numericInput("gamma", "gamma:", value=0.01),
                        numericInput("coef0", "coef0:", value=0)
      ),
      
      # Global parameters
      numericInput("cost", "C-cost:", value=1),
      numericInput("k", "k-fold validation:", value=1),
      
      # Number of dimensions in PCA compression
      sliderInput("kPCA",
                  "kPCA complexity (compressed search only):",
                  min = 1,
                  max = 14,
                  value = 1)
      
    ),
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
          tabPanel("Manual Search",
            plotOutput("pcaPlot"),
            verbatimTextOutput("pcaSummary")
          ),
          tabPanel("Automatic Search",
            plotOutput("tunedPlot"),
            verbatimTextOutput("tunedSummary"),
            verbatimTextOutput("tunedPerf")
          ),
          tabPanel("Automatic Search (compressed)",
                   plotOutput("tunedPCAPlot"),
                   verbatimTextOutput("tunedPCASummary"),
                   verbatimTextOutput("tunedPCAPerf")
          )
      ))
  )
))