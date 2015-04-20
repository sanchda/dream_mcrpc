library('R.matlab')
library('glmnet')
library('survival')

# Load and format data
featNames22 = readMat('../../data/halabi_22_feat_names.mat');
featNames22 = featNames22$f22.feat.names;
featNames22 = unlist( featNames22 );
survival = readMat('../../data/cleaned_surv.mat');
censor   = readMat('../../data/cleaned_censor.mat');
features = readMat('../../data/cleaned_ind.mat');
features22 = readMat('../../data/cleaned_ind22.mat');

# Clean variables a bit
censor = censor$censor[,1];
survival = survival$surv.var[,1];
features = features22$ind.var22;


# Run the cox alasso model!
source("DAS_cox_alasso.r");
result = alasso_cox(NN = 10, survival, censor, features, 1)

source("halabi_cox_alasso.r");
result = alasso_cox(NN = 10, survival, censor, features, 1)


# For testing purposes


# Test model by injecting coeffs into other coxph
cv.fit <- cv.glmnet(features, Surv(survival, censor), family = "cox", maxit = 1000)
fit <- glmnet(features, Surv(survival, censor), family = "cox", maxit = 1000)

# Run the coxph model; inject coeffs from Halabi
cox_model = coxph(Surv(survival, censor)~ ., data = as.data.frame(features[,abs(result[2,]) > 0.001]) )
cox_model$coefficients = result[2, abs(result[2,]) > 0.001 ]

# Now to obtain the 12 month estimate:
# Show results
source("metrics.R");
results = showSurvMetrics(12, censor[,1], survival[,1], cox_model, features[,abs(result[2,]) > 0.001], coeffs[abs(result[2,]) > 0.001])


thisEstimate = results$estimate;
plot(thisEstimate)