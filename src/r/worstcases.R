#Given a set of predictions and actual answers, which subset has the largest deviation


#The percentage of bad cases out of the whole group
badperc = .5

#Prediction: column 1.  Actual column 2

predact = matrix(abs(runif(2*100)),100)


maddiff = abs(predact[,1]-predact[,2])

#Cutoff
v = quantile(maddiff, badperc)

answer = which(maddiff>v)


