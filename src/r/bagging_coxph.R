library("glmnet", lib.loc="~/R/win-library/3.1")
library('survival')
library('timeROC')

# FA: Assuming the working folder is ...dream_mcrpc\src\r
# trainer = read.csv("C:/Users/jjklobusicky/Downloads/imputedtrainingset.csv",header = FALSE)
trainer = read.csv("../../data/imputedtrainingset.csv",header = TRUE)
trainer = trainer[,-(1:2)] # remove PAT_ID and GLEAS_DX
tester = read.csv("../../data/imputedtestset.csv",header = TRUE)
tester = tester[,-1] # remove PAT_ID

#Survival times
survive = read.csv("../../data/cleaned_surv.csv",header = TRUE)
censor = read.csv("../../data/cleaned_censor.csv",header = TRUE)

library('R.matlab')

# Import halabi feature names
featNames22 = readMat("../../data//halabi_22_feat_names.mat");
featNames22 = featNames22$f22.feat.names;
featNames22 = unlist( featNames22 );
ii = which(featNames22=="GLEAS_DX")
featNames22 = featNames22[-ii]

# Find the indices of the 21 features used in Halabi paper
fin = array(0,c(1,length(featNames22)));
for(i in 1:length(featNames22))
{
  fin[i] = which(colnames(trainer)==featNames22[i]);
}

## Depending on how many of the features you want to use set the Active.Index below
#This part does the actual dimension reduction from the 41 variables.  I wouldn't worry about this too much, unless you want to use the larger dataset
# 1
# newtrainer = as.matrix(trainer)
# cv.fit <- cv.glmnet(newtrainer, Surv(survive[,1], censor[,1]), family = "cox", maxit = 1000)
# fit <- glmnet(newtrainer, Surv(survive[,1], censor[,1]), family = "cox", maxit = 1000)
# Coefficients <- coef(fit, s = cv.fit$lambda.min)
# Active.Index <- which(Coefficients != 0)
# Active.Coefficients <- Coefficients[Active.Index]
# 2
# Active.Index = 1:ncol(trainer)
# 3
Active.Index = fin;

## Depending on how much of the training data you want to use set the indices below
# set the seed to make your partition reproductible
# set.seed(123)
# smp_size <- floor(0.75 * nrow(trainer))
# train_ind <- sample(seq_len(nrow(trainer)), size = smp_size) # Subset of the training set
train_ind = 1:nrow(trainer); # The entire set of samples

# This part does the bagging
nbag = 10000;
nsmp = 160; # 10% of the total sample size
tater = trainer[train_ind,Active.Index];
cens_tr = data.frame(censor[train_ind,1])
surv_tr = data.frame(survive[train_ind,1])
# estdata = trainer[,Active.Index]; # portion of training data that we use in bagging
# cens_tt = data.frame(censor[,1])
# surv_tt = data.frame(survive[,1])
estdata = trainer[-train_ind,Active.Index] # use the training set itself for testing as well
cens_tt = data.frame(censor[-train_ind,1])
surv_tt = data.frame(survive[-train_ind,1])
testdata = tester[,Active.Index]; # the real test data that we evaluate for each bagging iteration
testscores = matrix(0,nrow(testdata),nbag); # store the risk scores for the test data
# cox_list <- vector('list',nbag); # store cox models from each iteration
auc_arr <- array(0,c(1,nbag)); # save the train auc values to use them later for averaging models
idx_list <- matrix(0,nbag,nsmp) # save the indices for each iteration to reproduce results later

#Now to obtain the N month estimate:
months = 30;
days = months*30;

start <- Sys.time ()
count <- 0 # count the number of iterations that crashed
for (b in 1:nbag){
  idx = sample(nrow(censor),nsmp,replace=T);
  # Do exception handling using "try" to continue the next iteration if it crashes in coxph(...)
  result <- try(cox_model <- coxph(Surv(surv_tr[idx,1], cens_tr[idx,1])~ ., tater[idx,]),silent=TRUE);
  if(class(result) == "try-error"){ 
#     print("Error")
    count = count+1
    auc_arr[b] = 0;
#     cox_list[[b]] = NULL;
    idx_list[b,] = -1
    next;
  }
    
  estimado = survfit(cox_model, newdata = estdata)  
  y = get('time',estimado)
  k = which(y >= days)[1] # use y values beyond survival point
  diff_1 = (y[k]-days)/(y[k]-y[k-1]) # (y_k - months*30)/(y_k - y_{k-1})
  diff_2 = (days-y[k-1])/(y[k]-y[k-1]) # (months*30 - y_{k-1})/(y_k - y_{k-1})
  x = get('surv', estimado)
  p2 = x[k,]*diff_1 + x[k-1,]*diff_2;
  estvector = 1-p2
  
  Q = timeROC(surv_tt[,1],cens_tt[,1],estvector,other_markers = NULL,1, weighting = 'marginal',days)
  auc_arr[b] = Q$AUC[2];
#   cox_list[[b]] <- cox_model;
  idx_list[b,] = idx

  # evaluate the test data
  testimado = survfit(cox_model, newdata = testdata)  
  y = get('time',testimado)
  k = which(y >= days)[1] # use y values beyond survival point
  diff_1 = (y[k]-days)/(y[k]-y[k-1]) # (y_k - months*30)/(y_k - y_{k-1})
  diff_2 = (days-y[k-1])/(y[k]-y[k-1]) # (months*30 - y_{k-1})/(y_k - y_{k-1})
  x = get('surv', testimado)
  pp = x[k,]*diff_1 + x[k-1,]*diff_2;
  testscores[,b] = 1-pp

#   if (b %% 1000 == 0) {
#     print(c("iteration:",b,"maxauc:",max(auc_arr)))
#     Sys.time () - start
#   }
}
Sys.time () - start