library('glmnet')
library('survival')
library('R.matlab')

# Import data
featNames22 = readMat('../../data/halabi_22_feat_names.mat');
featNames22 = featNames22$f22.feat.names;
featNames22 = unlist( featNames22 );
survival = readMat('../../data/cleaned_surv.mat');
censor   = readMat('../../data/cleaned_censor.mat');
features = readMat('../../data/cleaned_ind.mat');
features22 = readMat('../../data/cleaned_ind22.mat');


# Load data from Matlab objects; vectorize matrices
features = features22$ind.var22;
survival = (survival$surv.var)[,1];
censor = (censor$censoring)[,1];


cv.fit <- cv.glmnet(features, Surv(survival, censor), family = "cox", maxit = 1000)
fit <- glmnet(features, Surv(survival, censor), family = "cox", maxit = 1000)


Coefficients <- coef(fit, s = cv.fit$lambda.min);
coeffs = as.matrix(Coefficients);

# Now getting estimates based on survival fits
# data-framization!
censor = data.frame(censor);
names(censor) = "censor";
features = data.frame(features);
names(features) = featNames22;
survival = data.frame(survival)
names(survival) = "survival";

cox_model = coxph(Surv(survival[,1], censor[,1])~ ., data = features[, abs(coeffs) > 0.001])


# Now to obtain the 12 month estimate:
# Show results
source("metrics.R");
featFrame = as.data.frame(features);
names(featFrame) = featNames22;
results = showSurvMetrics(12, censor[,1], survival[,1], cox_model, featFrame, coeffs)

thisEstimate = results$estimate;
plot(thisEstimate)
