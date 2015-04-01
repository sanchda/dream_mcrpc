require('regex');

setwd('/home/dasanchez/dev/DREAM_prostate/dream_mcrpc');
coreData    = read.csv('data/CoreTable_training.csv',stringsAsFactors=FALSE);

# Filter out 
coreData$AGEGRP = as.numeric( sub( ">=", "", coreData$AGEGRP) );