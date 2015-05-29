library("glmnet", lib.loc="~/R/win-library/3.1")
library('survival')
library('timeROC')

# FA: Assuming the working folder is ...dream_mcrpc/src/r
# trainer = read.csv("../../data/default8pcatrain.csv",header = FALSE)
# tester = read.csv("../../data/default8pca.csv",header = FALSE)
trainer = read.csv("../../data/energypcatrain.csv",header = FALSE)
tester = read.csv("../../data/energypca.csv",header = FALSE)

#Survival times
survive = read.csv("../../data/cleaned_surv.csv",header = TRUE)
censor = read.csv("../../data/cleaned_censor.csv",header = TRUE)

## Depending on how many of the features you want to use set the Active.Index below
#This part does the actual dimension reduction from the 41 variables.  I wouldn't worry about this too much, unless you want to use the larger dataset
newtrainer = as.matrix(trainer)
cv.fit <- cv.glmnet(newtrainer, Surv(survive[,1], censor[,1]), family = "cox", maxit = 1000)
fit <- glmnet(newtrainer, Surv(survive[,1], censor[,1]), family = "cox", maxit = 1000)
Coefficients <- coef(fit, s = cv.fit$lambda.min)
Active.Index <- which(Coefficients != 0)
Active.Coefficients <- Coefficients[Active.Index]
# Active.Index = 1:ncol(trainer)

## Depending on how much of the training data you want to use set the indices below
# set the seed to make your partition reproductible
set.seed(123)
smp_size <- floor(0.75 * nrow(trainer))
train_ind <- sample(seq_len(nrow(trainer)), size = smp_size) # Subset of the training set
# train_ind = 1:nrow(trainer); # The entire set of samples

cens_tr = data.frame(censor[train_ind,1])
surv_tr = data.frame(survive[train_ind,1])
tater = data.frame(trainer[train_ind,Active.Index])
cox_model = coxph(Surv(surv_tr[,1], cens_tr[,1])~ ., tater)

#Now to obtain the N month estimate:
#How many months am I estimating on?
months = 30
days = months*30
estdata = trainer[-train_ind,Active.Index]; # use the remaning portion as 
cens_tt = data.frame(censor[-train_ind,1])
surv_tt = data.frame(survive[-train_ind,1])
# estdata = trainer[,Active.Index] # use the training set itself for testing as well
# cens_tt = data.frame(censor[,1])
# surv_tt = data.frame(survive[,1])
testdata = tester[,Active.Index]

start <- Sys.time ()
estimado = survfit(cox_model, newdata = estdata) 
# estimado = survfit(cox_model, newdata = testdata)  # If evaluating the real test data
y = get('time',estimado)
k = which(y >= days)[1] # use y values beyond survival point
diff_1 = (y[k]-days)/(y[k]-y[k-1]) # (y_k - months*30)/(y_k - y_{k-1})
diff_2 = (days-y[k-1])/(y[k]-y[k-1]) # (months*30 - y_{k-1})/(y_k - y_{k-1})
x = get('surv', estimado)
p2 = x[k,]*diff_1 + x[k-1,]*diff_2;
estvector = 1-p2
Sys.time () - start

# If you want to see the training error
Q = timeROC(surv_tt[,1],cens_tt[,1],estvector,other_markers = NULL,1, weighting = 'marginal',days)
#And your AUC is...
print(Q$AUC)
