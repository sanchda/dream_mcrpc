#Judging how well everything works

#At what times am I basing my estimates?

#What are my risk scores at time T
showSurvMetrics = function(months, delta, time, V) {
  library('timeROC');
  times = c(months*30);

Q = timeROC(time,delta,V,other_markers = NULL,1, weighting = 'marginal',times)

return(Q);

}