firstLastMean = function(V) {
  thisV = V[ !is.na(V) ];
  thisV = thisV[ !is.null(V) ];
  thisV = thisV[ !is.nan(V) ];
  
  return( c(thisV[1], thisV[ length(thisV) ], mean( thisV ) ) );
}

getEventColumns = function(baseTable, patientNames, eventNames, eventPatName, eventValName, eventColName) { 
  # Generate friendly names for columns
  eventColNames = tolower( gsub( " ", "_", eventNames) );
  eventColNames = gsub("[\\)\\(]", "", eventColNames);
  
  # Create an empty data frame for holding the stuff
  eventOutput = as.data.frame( matrix( NA, length(patientNames), 3*length(eventColNames)) );
  rownames( eventOutput ) = patientNames;
  colnames( eventOutput ) = as.vector( t(matrix( c( sprintf("%s_first", eventColNames), sprintf("%s_last", eventColNames), sprintf("%s_mean", eventColNames) ), length(eventColNames), 3)) );
  
  for( thisPatient in patientNames ) {
    theseRows = baseTable[ baseTable[,eventPatName] %in% thisPatient, ];
    
    for( i in 1:length(eventNames) ) {
      hotRows = theseRows[ theseRows[,eventColName] %in% eventNames[i], ];
      if( nrow( hotRows ) == 0 ) {
        next;
      }
      
      thisVec = firstLastMean( hotRows[,eventValName] );
      eventOutput[ patientNames %in% thisPatient, ( (i-1)*3+1 ):( i*3 ) ] = thisVec;
      
    }
  }

  eventOutput[,eventPatName] = patientNames;
  
  return( eventOutput );

}
  