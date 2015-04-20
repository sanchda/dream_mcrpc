library(R.matlab)

# Load and format data
survival = readMat('../../data/cleaned_surv.mat');
censor   = readMat('../../data/cleaned_censor.mat');
features = readMat('../../data/cleaned_ind.mat');
features22 = readMat('../../data/cleaned_ind22.mat');


# Run the cox alasso model!
source("DAS_cox_alasso.r");
result = alasso_cox(NN = 10, survival$surv.var, censor$censoring, features22$ind.var22, 1)

source("halabi_cox_alasso.r");
result = alasso_cox(NN = 10, survival$surv.var, censor$censoring, features22$ind.var22, 1)


# For testing purposes
NN = 10
time = survival$surv.var;
delta = censor$censoring;
z = features22$ind.var22;
lambda = 1;