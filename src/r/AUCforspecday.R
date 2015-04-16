library(timeROC)

#Prediction Matrix
nopatients = 1600
nodays = 1000


A1 = matrix(abs(runif(nodays*nopatients)),nopatients)

#Results
A2 = matrix(rbinom(nopatients*nodays,1,.5),ncol= nodays,nrow=nopatients)
  
  
 

#Build a vector that gives that date of death
  
  deathvec = rep(0,nopatients)


  for (i in 1:nopatients){
    deathvec(i) = min(which(A2[i,] == 1))
}


#Recover AUC scores for a specific day

AUConspecday = rep(0,nodays)
for (i in 1:nodays){
Q = timeROC(deathvec,rep(1,nopatients),A1[,i],other_markers = NULL,1, weighting = 'marginal',i)
AUConspecday[i] = as.numeric(Q$AUC)
}


    