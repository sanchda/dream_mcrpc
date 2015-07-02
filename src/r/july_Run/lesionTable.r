coreTable = read.csv("data\\raw_data\\CoreTable_training.csv", stringsAsFactors=FALSE);
lesTable  = read.csv("data\\raw_data\\LesionMeasure_training.csv", stringsAsFactors=FALSE, na.strings=c("NA","NaN", " ", "", "."));

# Process 