#Judging how well everything works




#At what times am I basing my estimates?




#What are my risk scores at time T
V = estvector

times = c(12*30)





delta = censor[,1]

time = survive[,1]

Q = timeROC(time,delta,V,other_markers = NULL,1, weighting = 'marginal',times)

