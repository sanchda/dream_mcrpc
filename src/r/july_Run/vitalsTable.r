# Load dependencies
library("dplyr");

# Load the data
coreTable = read.csv("data\\raw_data\\CoreTable_training.csv", stringsAsFactors=FALSE);
vitTable  = read.csv("data\\raw_data\\VitalSign_training.csv", stringsAsFactors=FALSE, na.strings=c("NA","NaN", " ", "", ".", "ND"));

# Pre-process the data
vitTable = vitTable[ !is.na( vitTable$VSORRES ), ];
vitTable = arrange( vitTable, RPT, VSTEST, desc(VSDT_PC) );


firstLastMean = function(V) {
 thisV = V[ !is.na(V) ];
 thisV = thisV[ !is.null(V) ];
 thisV = thisV[ !is.nan(V) ];
 
 return( c(thisV[1], thisV[ length(thisV) ], mean( thisV ) ) );
}

patients = unique( vitTable$RPT );
vitalTestsNames = unique( vitTable$VSTEST );
vitalTestsNames = vitalTestsNames[ ! (vitalTestsNames %in% "BODY MASS INDEX") ];
vitalTests = tolower( gsub( " ", "_", vitalTestsNames) );

# Create an empty data frame for holding the stuff
vitOutput = as.data.frame( matrix( NA, length(patients), 3*length(vitalTests)) );
rownames( vitOutput ) = patients;
colnames( vitOutput ) = as.vector( t(matrix( c( sprintf("%s_first", vitalTests), sprintf("%s_last", vitalTests), sprintf("%s_mean", vitalTests) ), length(vitalTests), 3)) );

for( thisPatient in patients ) {
  theseRows = vitTable[ vitTable$RPT %in% thisPatient, ];
  
  for( i in 1:length(vitalTestsNames) ) {
    hotRows = vitTable[ theseRows$VSTEST %in% vitalTestsNames[i], ];
    if( nrow( hotRows ) == 0 ) {
      next;
    }
    thisVec = firstLastMean( hotRows$VSORRES );
    vitOutput[ patients %in% thisPatient, ( (i-1)*3+1 ):( i*3 ) ] = thisVec;
  
  }
}

vitOutput$RPT = patients;


# So now what you want to do is this:
coreTable2 = merge(coreTable, vitOutput, by = "RPT", all = TRUE);