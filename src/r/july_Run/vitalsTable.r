# Load dependencies
library("dplyr");
source("src\\r\\july_Run\\getEventColumns.r");

# Load the data
coreTable = read.csv("data\\raw_data\\CoreTable_training.csv", stringsAsFactors=FALSE);
vitTable  = read.csv("data\\raw_data\\VitalSign_training.csv", stringsAsFactors=FALSE, na.strings=c("NA","NaN", " ", "", ".", "ND"));



firstLastMean = function(V) {
 thisV = V[ !is.na(V) ];
 thisV = thisV[ !is.null(V) ];
 thisV = thisV[ !is.nan(V) ];
 
 return( c(thisV[1], thisV[ length(thisV) ], mean( thisV ) ) );
}

