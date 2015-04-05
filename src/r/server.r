# name: server.r
# purpose: interactive exploratory tool for DREAM 9.5
# date created: 3/24/2015
# author: David Sanchez
# description:
#
#

# Make sure to install things!
# install.packages('cgdsr')
# install.packages('shiny')
# install.packages('e1071')

# Load the library
library('shiny')
library('ggplot2')
library('e1071')

# Load the data
# Don't use data.table; this set is tiny!
vitalSign = read.csv("data/VitalSign_training.csv");
priorMed  = read.csv("data/PriorMed_training.csv");
medHistory= read.csv("data/MedHistory_training.csv");
lesMeasure= read.csv("data/LesionMeasure_training.csv");
labVals   = read.csv("data/LabValue_training.csv");
coreTable = read.csv("data/CoreTable_training.csv");


# Split the data into logical blocks


# Manually fix some categorical variables
# Target
targetVar = as.integer(targetVar);
# Demographics
demoVars$SEX         = as.integer(demoVars$SEX);
demoVars$PRIOR.MAL   = as.integer(demoVars$PRIOR.MAL);
demoVars$PRIOR.CHEMO = as.integer(demoVars$PRIOR.CHEMO);
demoVars$PRIOR.XRT   = as.integer(demoVars$PRIOR.XRT);

# Handle missing values.  Here, we just add the mean value of that feature.
# This is somewhat dubious, but the point is:  depending on the analysis, disturb
# the geometry or joint probability (can be different!) as little as possible, since
# you don't want to _ADD_ information by imputing!
#
# Oleg recommends adding white noise instead--would agree if more rows...
for ( i in 1:ncol(demoVars) ){
  demoVars[is.na(demoVars[, i]), i] <- mean(demoVars[, i],  na.rm = TRUE);
}

for ( i in 1:ncol(labVars) ){
  labVars[is.na(labVars[, i]), i] <- mean(labVars[, i],  na.rm = TRUE);
}

for ( i in 1:ncol(geneVars) ){
  geneVars[is.na(geneVars[, i]), i] <- mean(geneVars[, i],  na.rm = TRUE);
}

# Define server logic
shinyServer(function(input, output) {
  
  # Choose the sets specified by the user
  thisData = reactive({
    switch( input$sets,
        "Demographics"= demoVars,
        "Labs"        = labVars,
        "Genes"       = geneVars,
        "demo + lab"  = cbind(demoVars, labVars),
        "demo + gene" = cbind(demoVars, labVars),
        "lab + gene"  = cbind(labVars,  geneVars),
        "all"         = cbind(demoVars, labVars, geneVars)
    )
  })
  
  # Perform PCA
  pca.rows = reactive({
    x = thisData();
    pca.vars = prcomp(~., x , scale = TRUE)
    as.data.frame( predict( pca.vars, x ) )
  })
  
  # Run manual SVM
  model.svm = reactive({
    df = cbind( thisData(), targetVar );  # Yup, cbinding at the head of every reactive({})!
                                          # would have been smarter to add it to the core data,
                                          # but I didn't want it to participate in preprocessing operations
    
    # Each kernel has its own hyperparameters, so might as well just call each one
    # TODO: are poly and sigmoid not converging..?
    #
    switch(input$kernel,
           "linear"  = svm(as.factor(targetVar) ~ ., data = df, kernel = "linear",                                                         cost=input$cost, k=input$k),
           "radial"  = svm(as.factor(targetVar) ~ ., data = df, kernel = "radial",  gamma=input$gamma,                                     cost=input$cost, k=input$k),
           "poly"    = svm(as.factor(targetVar) ~ ., data = df, kernel = "poly",    gamma=input$gamma, deg = input$deg, coef0=input$coef0, cost=input$cost, k=input$k),
           "sigmoid" = svm(as.factor(targetVar) ~ ., data = df, kernel = "sigmoid", gamma=input$gamma,                  coef0=input$coef0, cost=input$cost, k=input$k)
    )
  })
  
  # Run auto-tuned SVM
  tuned.svm = reactive({
    df = thisData();

    switch(input$kernel,
           "linear"  = tune.svm(df, as.factor(targetVar), kernel = "linear"),
           "radial"  = tune.svm(df, as.factor(targetVar), kernel = "radial"),
           "poly"    = tune.svm(df, as.factor(targetVar), kernel = "poly"),
           "sigmoid" = tune.svm(df, as.factor(targetVar), kernel = "sigmoid")
    )
  })
  
  # Run auto-tuned SVM on a subset of the PCA space
  tuned.svm.pca = reactive({
    df = pca.rows()[,1:input$kPCA];
    
    switch(input$kernel,
           "linear"  = tune.svm(df, as.factor(targetVar), kernel = "linear"),
           "radial"  = tune.svm(df, as.factor(targetVar), kernel = "radial"),
           "poly"    = tune.svm(df, as.factor(targetVar), kernel = "poly"),
           "sigmoid" = tune.svm(df, as.factor(targetVar), kernel = "sigmoid")
    )
  })
  
  
  # Make plot of PCA along chosen coords
output$pcaPlot <- renderPlot({
  # build DF holding data and colors from original PCA
  colors = c("red", "blue");
  colors = colors[targetVar];
  df = cbind(pca.rows(), colors) # because ggplot2 prefers data frames
  
  # build DF holding data and colors for just the support vectors
  thisIndex = model.svm()$index;
  SV_rows = pca.rows()[thisIndex,];
  SV_colors = colors[thisIndex];
  SV_df = cbind(SV_rows, SV_colors)
  
  # Now visualize, with triangles over support vectors
  p = ggplot(df,    mapping=aes_string(x=variable.names(df)[input$pca1],    y=variable.names(df)[input$pca2],    colour="colors"))
  p = p + geom_point()
  p + geom_point(SV_df, shape=2, mapping=aes_string(x=variable.names(SV_df)[input$pca1], y=variable.names(SV_df)[input$pca2], colour="SV_colors", size="10"))

})

# Show summary statistics of manually tuned SVM
output$pcaSummary = renderText({
  capture.output(summary( model.svm() ))
})


# Make a plot of the tuned SVM performance
output$tunedPlot <- renderPlot({
  # build DF holding data and colors from original PCA
  colors = c("red", "blue");
  colors = colors[targetVar];
  df = cbind(pca.rows(), colors) # because ggplot2 prefers data frames
  
  # build DF holding data and colors for just the support vectors
  thisIndex = tuned.svm()$best.model$index;
  SV_rows = pca.rows()[thisIndex,];
  SV_colors = colors[thisIndex];
  SV_df = cbind(SV_rows, SV_colors)
  
  # Now visualize, with triangles over support vectors
  p = ggplot(df,  mapping=aes_string(x=variable.names(df)[input$pca1],    y=variable.names(df)[input$pca2],    colour="colors"))
  p = p + geom_point()
  p + geom_point(SV_df, shape=2, mapping=aes_string(x=variable.names(SV_df)[input$pca1], y=variable.names(SV_df)[input$pca2], colour="SV_colors", size="10"))
  
})

# Show summary statistics of automatically tuned SVM
output$tunedSummary = renderText({
  capture.output(summary( tuned.svm()$best.model ))
})

# Show perf of best automatically tuned SVM
output$tunedPerf = renderText({
  capture.output( tuned.svm()$best.performance )
})


# Make a plot of the tuned SVM (on PCA data) performance
output$tunedPCAPlot <- renderPlot({
  # build DF holding data and colors from original PCA
  colors = c("red", "blue");
  colors = colors[targetVar];
  df = cbind(pca.rows(), colors) # because ggplot2 prefers data frames
  
  # build DF holding data and colors for just the support vectors
  thisIndex = tuned.svm.pca()$best.model$index;
  SV_rows = pca.rows()[thisIndex,];
  SV_colors = colors[thisIndex];
  SV_df = cbind(SV_rows, SV_colors)
  
  # Now visualize, with triangles over support vectors
  p = ggplot(df,  mapping=aes_string(x=variable.names(df)[input$pca1],    y=variable.names(df)[input$pca2],    colour="colors"))
  p = p + geom_point()
  p + geom_point(SV_df, shape=2, mapping=aes_string(x=variable.names(SV_df)[input$pca1], y=variable.names(SV_df)[input$pca2], colour="SV_colors", size="10"))
  
})

# Show summary statistics of automatically tuned SVM
output$tunedPCASummary = renderText({
  capture.output(summary( tuned.svm.pca()$best.model ))
})

# Show perf of best automatically tuned SVM
output$tunedPCAPerf = renderText({
  capture.output( tuned.svm.pca()$best.performance )
})



})