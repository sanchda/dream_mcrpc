library(R.matlab)


# Load and format data
survival = readMat('../../data/cleaned_surv.mat');
censor   = readMat('../../data/cleaned_censor.mat');
features = readMat('../../data/cleaned_ind.mat');
features22 = readMat('../../data/cleaned_ind22.mat');


# Run the cox alasso model!
source("cox_alasso.R");
result = alasso_cox(NN = 10, survival$surv.var, censor$censoring, features22$ind.var22, 1)
