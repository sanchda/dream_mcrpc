function PREDICTION=PCA_regression(TRAIN_INPUT,TRAIN_OUTPUT,TEST_INPUT,TEST_OUTPUT)
% we assume that TRAIN_INPUT,TEST_INPUT contains values 0 or 1
% we assume that TEST_INPUT, TRAIN_INPUT is (a) dense, no missing values, (b) real-valued and (c) normalized
% performs PCA compression
% runs a binary classifier (logistic regression) on compressed data
% outputs probabilities of outcome 1 for all points in TEST_INPUT

N=size(TEST_INPUT,2); % number of snapshots
n=size(TEST_INPUT,1); % dimension of input

% define weights matrix. Contains relative values of individual patient
% records
W=diag(ones(1,size(TR_INPUT,1)));
% this matrix needs to be positive definite!!!

% define metric matrix. Contains relative values of individual observations
M=diag(ones(1,size(TR_INPUT,2)));
% this matrix needs to be positive definite!!!

% define dimension of the reduced model
k=10;

C=TRAIN_INPUT'*W*TRAIN_INPUT;
[evector,evalue]=eig(M*C,'nobalance');
evalue=diag(evalue);
[esorted,ind_esorted]=sort(abs(evalue),'descend');
esorted=real(esorted); % smaller eigenvalues can have imaginary numerical noise
% this is a good place to re-define k 
total_energy=sum(esorted);
partial_energy=0;
for k=1:N
	partial_energy=partial_energy+esorted(k)/total_energy;
	if partial_energy>0.99
		break
	end
end
% or comment this out and use default k

% use sorted eigenvalues, eigenvectors from now on
phi_temp=evector;
for i=1:N
    PHI(:,i)=phi_temp(:,ind_esorted(i));
    % and also normalize
    temp=PHI(:,i);
    norm_coeff=sqrt(temp'*temp);
    PHI(:,i)=PHI(:,i)/norm_coeff;
end
% truncate to get the projection matrix
PHI=PHI(:,1:k);

RED_TR_INPUT=TRAIN_INPUT*PHI;
RED_TS_INPUT=TEST_INPUT*PHI;

% for prediction, use multinomial logistic regression, outputs matrix of coefficients
B=mnrfit(RED_TR_INPUT,TR_OUT+1);  % +1 because Matlab wants outputs to be named 1,2 not 0,1
TEMP=mnrval(B,RED_TS_INPUT);

PREDICTION=TEMP(:,2);
end