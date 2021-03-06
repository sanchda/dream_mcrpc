loglik = function(n,delta,z,beta){
  L = 0.0
  for(i in 1:n){
    temp = 0.0
    for(j in i:n) temp = temp + exp(sum(beta*z[j,])) 
    L = L - delta[i]*(sum(beta*z[i,])-log(temp))
  }         
  return(L)
} 

dloglik = function(n,delta,z,beta){
  p = length(beta)
  L = numeric(p)
  for(i in 1:n){
    temp = 0.0
    temp1 = numeric(p)
    for(j in i:n){
      temp = temp + exp(sum(beta*z[j,]))
      temp1 = temp1 + z[j,]*exp(sum(beta*z[j,]))
    }
    L = L - delta[i]*(z[i,] - temp1/temp)
  }
  return(L) 
}  

ddloglik = function(n,delta,z,beta){
  p = length(beta)
  L = matrix(0,nrow=p,ncol=p)
  for(i in 1:n){
    temp = 0.0
    temp1 = numeric(p)
    temp2 = matrix(0,nrow=p,ncol=p)
    for(j in i:n){
      temp = temp + exp(sum(beta*z[j,]))
      temp1 = temp1 + z[j,]*exp(sum(beta*z[j,]))
      temp2 = temp2 + z[j,]%*%t(z[j,])*exp(sum(beta*z[j,]))
    }
    L = L + delta[i]*(temp2/temp - temp1%*%t(temp1)/(temp*temp))
  }
  return(L) 
}  


ginv = function(X, tol = sqrt(.Machine$double.eps)){
  s = svd(X)
  nz = s$d > tol * s$d[1]
  if(any(nz)) s$v[,nz] %*% (t(s$u[,nz])/s$d[nz])
  else X*0
}

normalize = function(x){
  y = (x-mean(x))/sqrt(sum((x-mean(x))^2))
  return(y)
}


wshoot <- function(n,p,x,y,init,weight,lambda,maxiter,tol)
{
  Q = t(x)%*%x
  B = t(x)%*%y
  i=0
  status = 0
  
  lams =lambda*weight 
  oldbeta <- init
  tmpbeta <- oldbeta
  
  while (i<maxiter && status==0){ 
    for (j in 1:p){ 
      s<-ss2(j,tmpbeta,Q,B)
      if (s > lams[j]) 
        tmpbeta[j]<-(lams[j]-s)/(2*Q[j,j])
      else if (s < (-lams[j]) ) 
        tmpbeta[j]<-(-lams[j]-s)/(2*Q[j,j])
      else
        tmpbeta[j]<- 0.0
    }
    dx<-max(abs(tmpbeta-oldbeta))
    oldbeta <- tmpbeta
    if (dx<=tol) 
      status <- 1 
    i <- i+1
  }
  tmpbeta
}

ss2 <- function(j,tmpb,Q,B)
{
  a <- sum(tmpb*Q[,j])-tmpb[j]*Q[j,j]
  s <- 2*(a-B[j])
  return(s)
}


lse <- function(x,y)
{ Q <- t(x)%*%x
  P <- t(x)%*%y
  beta <- solve(Q,P)
  beta
}


alasso_cox <- function(NN = 10, time, delta, z, lambda)
{
  iter = 100
  tol = 1.0e-10
  n = length(time)
  p = length(z[1,])
  true.sd = sqrt(apply(z,2,var)*(n-1))
  delta = delta[order(time)]
  ordz = z[order(time),] 
  z = apply(ordz,2,normalize)
  sd = sqrt(apply(z,2,var)*(n-1))
  #computing initial estimates
  ii = 0
  beta = numeric(p)
  while(ii < NN){
    fn=loglik(n,delta,z,beta)
    G=dloglik(n,delta,z,beta)
    H=ddloglik(n,delta,z,beta)
    
    X = chol(H) 
    vecY = forwardsolve(t(X),H%*%beta-G)
    lsbeta = lm(vecY~-1+X)$coef
    beta1 = lsbeta
    dx = max(abs(beta1-beta))
    ii = ii + 1
    istop = ii
    if(dx <= 1.0e-5) ii = NN
    beta = beta1
  }
  inibeta = beta
  #computing adaptive-Lasso solutions
  sd = sd/abs(inibeta)
  ii = 0
  beta = numeric(p)
  while(ii < NN){
    fn=loglik(n,delta,z,beta)
    G=dloglik(n,delta,z,beta)
    H=ddloglik(n,delta,z,beta)
    
    X = chol(H) 
    vecY = forwardsolve(t(X),H%*%beta-G)
    lsbeta = lm(vecY~-1+X)$coef
    beta1 = wshoot(p,p,X,vecY,init=lsbeta,sd,lambda,iter,tol)
    dx = max(abs(beta1-beta))
    ii = ii + 1
    istop = ii
    if(dx <= 1.0e-5) ii = NN
    beta = beta1
  }
  beta = beta/true.sd
  inibeta = inibeta/true.sd
  return(rbind(t(inibeta),t(beta)))
} 

