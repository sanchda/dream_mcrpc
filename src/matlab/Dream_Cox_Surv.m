function [] = Dream_Cox_Surv(dep_col, ind_mat)
% Fits a Cox proportional hazards regression model on the data train,
% plotting the Cox estimate against the distribution

coxphopt = statset('coxphfit');
coxphopt.Display = 'final';
coxphopt.MaxIter = 50;

b = coxphfit( dep_col, ind_mat, 'options',coxphopt );



end

