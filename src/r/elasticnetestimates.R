library("glmnet", lib.loc="~/R/win-library/3.1")

#Let's get this stuff done with!!

library('survival')


tater = as.matrix(cleanertater)

survive = as.matrix(cleanersurv)

censor = as.matrix(cleanercensor)


cv.fit <- cv.glmnet(tater, Surv(survive[,1], censor[,1]), family = "cox", maxit = 1000)
fit <- glmnet(tater, Surv(survive[,1], censor[,1]), family = "cox", maxit = 1000)


Coefficients <- coef(fit, s = cv.fit$lambda.min)
Active.Index <- which(Coefficients != 0)
Active.Coefficients <- Coefficients[Active.Index]


#Now getting estimates based on survival fits

# survfit(fit, newdata = tater[1,])

#matricize!

censor = data.frame(censor)
tater = data.frame(tater)
survive = data.frame(survive)


cox_model = coxph(Surv(survive[,1], censor[,1])~ ., data = tater[,Active.Index])



#Now to obtain the 12 month estimate:

estvector = matrix(0,1600,1)



months = 18
for (j in 2:dim(censor)[1]){

estimado = survfit(cox_model, newdata = tater[j,Active.Index])

x = get('surv', estimado)
y = get('time',estimado)

for (k in 2:length(y)){
  if (y[k]>= months*30){
    p2 = ((y[k]-months*30)/(y[k]-y[k-1]))*x[k-1]+((months*30-y[k-1])/(y[k]-y[k-1]))*x[k]
    break
  }
}
  
estvector[j] = 1-p2

}



plot(estimado)


