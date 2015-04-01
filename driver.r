require('regex');

setwd('/home/dasanchez/dev/DREAM_prostate/dream_mcrpc');
coreData    = read.csv('data/CoreTable_training.csv',stringsAsFactors=FALSE);

# Filter out non-numeric characters from ages
coreData$AGEGRP = as.numeric( sub( ">=", "", coreData$AGEGRP) );


# Conver race_c to numeric
coreData$RACE_C = as.numeric( as.factor( coreData$RACE_C ) );


# ECOG PS
coreData$ECOG_C[ coreData$ECOG_C == "." ] = "0"; # Just a guess
coreData$ECOG_C = as.numeric( coreData$ECOG_C );


# Disease site
# BONE RECTAL LYMPH_NODES KIDNEYS LUNGS LIVER PLEURA OTHER PROSTATE ADRENAL BLADDER PERITONEUM COLON HEAD_AND_NECK SOFT_TISSUE STOMACH PANCREAS THYROID ABDOMINAL


# Measurable disease
# Need to figure out what this means


# Opioid analgesic use
# This may be bad!
coreData$ANALGESICS = (coreData$ANALGESICS == "YES") + 0;


# LDH > 1 ULN


# LDH, U/L


# PSA, ng/mL


# Hemoglobin, g/dL


# Albumin g/dL


# Alkaline phosphatase, U/L


# Treatment arm
# One would think TRT1_ID, TRT2_ID, and TRT3_ID would be relevant, but doesn't seem to be the case.
