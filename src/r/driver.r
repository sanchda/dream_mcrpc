library(R.matlab)


# Load and format data
survival = readMat('../../data/cleaned_surv.mat');
censor   = readMat('../../data/cleaned_censor.mat');
features = readMat('../../data/cleaned_ind.mat');


# Run the cox alasso model!
source("cox_alasso.R");
result = alasso_cox(NN = 1, survival$surv.var, censor$censoring, features$ind.var, 1)