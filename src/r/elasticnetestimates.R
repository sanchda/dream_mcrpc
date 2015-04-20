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
tater = features22$ind.var22;
survive = (survival$surv.var)[,1];
censor = (censor$censoring)[,1];


cv.fit <- cv.glmnet(tater, Surv(survive, censor), family = "cox", maxit = 1000)
fit <- glmnet(tater, Surv(survive, censor), family = "cox", maxit = 1000)


Coefficients <- coef(fit, s = cv.fit$lambda.min)
Active.Index <- which(Coefficients != 0)
Active.Coefficients <- Coefficients[Active.Index]


# Now getting estimates based on survival fits
# data-framization!
censor = data.frame(censor);
names(censor) = "censor";
tater = data.frame(tater);
names(tater) = featNames22;
survive = data.frame(survive)
names(survive) = "survival";

cox_model = coxph(Surv(survive[,1], censor[,1])~ ., data = tater[,Active.Index])


#Now to obtain the 12 month estimate:
months = 18;


estvector = matrix(0,dim(tater)[1],1)
for (j in 2:dim(censor)[1]){

estimado = survfit(cox_model, newdata = tater[j,Active.Index])

x = get('surv', estimado)
y = get('time', estimado)

for (k in 2:length(y)) {
  
  if (y[k]>= months*30) {
    p2 = ((y[k]-months*30)/(y[k]-y[k-1]))*x[k-1]+((months*30-y[k-1])/(y[k]-y[k-1]))*x[k]
    break
  }
}
  
estvector[j] = 1-p2

}


# Show results!

plot(estimado)

source("metrics.R");
survMetrics = showSurvMetrics(12, censor[,1], survive[,1], estvector);

