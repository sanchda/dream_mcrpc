# Load the data
coreTable = read.csv("data\\raw_data\\CoreTable_training.csv", stringsAsFactors=FALSE);
labTable  = read.csv("data\\raw_data\\LabValue_training.csv", stringsAsFactors=FALSE);
lesTable  = read.csv("data\\raw_data\\LesionMeasure_training.csv", stringsAsFactors=FALSE);
medTable  = read.csv("data\\raw_data\\MedHistory_training.csv", stringsAsFactors=FALSE);
pmedTable = read.csv("data\\raw_data\\PriorMed_training.csv", stringsAsFactors=FALSE);
vitTable  = read.csv("data\\raw_data\\VitalSign_training.csv", stringsAsFactors=FALSE);

