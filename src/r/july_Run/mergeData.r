# Load dependencies
library("dplyr");
source("src\\r\\july_Run\\getEventColumns.r");


### Process vitalSign_training.csv
# Load the data
coreTable = read.csv("data\\raw_data\\CoreTable_training.csv", stringsAsFactors=FALSE);
vitTable  = read.csv("data\\raw_data\\VitalSign_training.csv", stringsAsFactors=FALSE, na.strings=c("NA","NaN", " ", "", ".", "ND"));

# Pre-process the data;
# Get rid of rows without scores
vitTable = vitTable[ !is.na( vitTable$VSORRES ), ];
vitTable = arrange( vitTable, RPT, VSTEST, desc(VSDT_PC) );

# Define inputs to getEventColumns
patients = unique( vitTable$RPT );
vitalTestsNames = unique( vitTable$VSTEST );
vitalTestsNames = vitalTestsNames[ ! (vitalTestsNames %in% "BODY MASS INDEX") ];

# Call to get min, max, mean of desired columns
newTable = getEventColumns(vitTable, patients, vitalTestsNames, "RPT", "VSORRES", "VSTEST");

# merge together coreTable with vitTable
coreTable = merge(coreTable, newTable, by = "RPT", all = TRUE);


### process LabValue_training.csv
labTable  = read.csv("data\\raw_data\\LabValue_training.csv", stringsAsFactors=FALSE, na.strings=c("NA","NaN", " ", "", ".", "ND"));

# Pre-process the data;
# Get rid of rows without scores
labTable = labTable[ !is.na( labTable$LBSTRESC ), ];

# Blank out rows with letters or dashes in the value
labTable$LBSTRESC = gsub(".*[A-Za-z\\-]+.*","", labTable$LBSTRESC);

# Some perfectly good numerics are cast to char because of additional data (>,<, etc)
labTable$LBSTRESC = gsub("[\\+\\<\\>\\=]","", labTable$LBSTRESC);

# Convert to numeric, drop rows which were set to NA
labTable$LBSTRESC = as.numeric( labTable$LBSTRESC );
labTable = labTable[ !is.na( labTable$LBSTRESC ), ];

# Now, list the different events according to the fraction of patients which have seen that event
# could be slightly different than ordering according to overall prevelance, especially if one study
# prescribed a given test on a weekly basis, and other studies did not do it.  Or something.
mergedNames = sprintf("%s___%s", labTable$RPT, labTable$LBTESTCD);
mergedNames = unique(mergedNames);
mergedNames = gsub(".*___","",mergedNames);
mergedNames = sort( table(mergedNames) , decreasing=TRUE);


# Rearrange for consistency
labTable = arrange( labTable, RPT, LBTESTCD, desc(LBDT_PC) );

# Define inputs to getEventColumns
patients = unique( labTable$RPT );
labTestsNames = rownames( mergedNames[1:50]);

# Call to get min, max, mean of desired columns
newTable = getEventColumns(labTable, patients, labTestsNames, "RPT", "LBTESTCD", "LBSTRESC");

# merge together coreTable with vitTable
coreTable = merge(coreTable, newTable, by = "RPT", all = TRUE);


