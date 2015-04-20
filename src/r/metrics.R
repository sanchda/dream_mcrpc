#Judging how well everything works

#At what times am I basing my estimates?

#What are my risk scores at time T
showSurvMetrics = function(months, delta, times, cox_model, features, coeffs) {
  library('timeROC');
  
  estvector = matrix(0,dim(features)[1],1);
  for(j in 2:dim(features)[1] ) {
    
    estimado = survfit(cox_model, newdata = features[j,abs(coeffs) > 0.001])
    
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

Q = list();
Q$estimate = estimado;
Q$ROCout = timeROC(times,delta,estvector,other_markers = NULL,1, weighting = 'marginal',c(months*30))


return(Q);

}