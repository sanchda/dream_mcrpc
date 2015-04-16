function PCAdemo
close all


% get variables

load dreamdata
INPUTS=B(:,5:end); % has missing entries!

OUTreal=B(:,2); % survival days
OUTbin=B(:,1); % 1=dead, 0=alive  % has missing entries!

% drop features with many missing entries, unimportant for now
INPUTS(:,[11,29,36,12])=[];

%disp(size(INPUTS));  % 37 features left
%disp(length(find(isnan(INPUTS)))/prod(size(INPUTS))*100);   % 2.4 percent still missing

% clean up remaining missing entries
TEMP=INPUTS;
for i=1:1600
    for j=1:37
        if isnan(INPUTS(i,j))
            INPUTS(i,j)=nanmean(TEMP(:,j));
        end
    end
end
clear TEMP  % cleanup done

% PCA and PREDICTION begin
% work with 'how many days' output only

% define training set, the rest goes into testing set
M=1000;
ind=randsample(1:1600,M);
TEMPX=INPUTS; TEMPY=OUTreal;
XTRAIN=TEMPX(ind,:); YTRAIN=TEMPY(ind);
TEMPX(ind,:)=[]; TEMPY(ind)=[];
XTEST=TEMPX; YTEST=TEMPY;
clear TEMPX
clear TEMPY


% attempt at weighting
W1=zeros(1,37);
    
% METRIC, or importance of each VARIABLE, by correlation
for i=1:37
    W1(i)=abs(corr(XTRAIN(:,i),YTRAIN));
    if isnan (W1(i))
        W1(i)=0;
    end
end
disp(W1);
figure(1); plot(sort(W1,'descend'),'r*-');

W1=W1/sum(W1);

% WEIGHTS, or importance of each SNAPSHOTS, by inverse of variance for now,
% substitute marginal importance later
for i=1:M
    W2(i)=log(YTRAIN(i))/log(10);
end

% by martinal importance



% PCA with weighting begins
N=37;
METRIC=diag(W1);
WEIGHTS=diag(W2);


% for testing:
%METRIC=eye(37);
%WEIGHTS=eye(M);
% that was for testing only

C=XTRAIN'*WEIGHTS*XTRAIN;

[evector,evalue]=eig(METRIC*C,'nobalance');
evalue=diag(evalue);
[esorted,ind_esorted]=sort(abs(evalue),'descend');
esorted=real(esorted); % smaller eigenvalues can have imaginary numerical noise
% this is a good place to re-define k 
total_energy=sum(esorted);
partial_energy=0;
for k=1:N
	partial_energy=partial_energy+esorted(k)/total_energy;
	if partial_energy>0.999
		break
	end
end
disp('Sufficient (recommended) k is'); disp(k); % we get 5 to 8
figure(2); plot(log(esorted)/log(10),'b*-');
% % or ignore all this and use default k
% k=6;

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

RED_TRAIN=XTRAIN*PHI;
RED_TEST=XTEST*PHI;

% try some predictions
b = regress(YTRAIN,RED_TRAIN);
% disp(b)
% size(b)

PRED=RED_TEST*b;

disp(corr(PRED,YTEST))



[TRUESORT,ind]=sort(YTEST,'descend');

PREDSORT=PRED(ind);



figure(3); hold on; plot(TRUESORT,'b'); plot(PREDSORT,'r');

ERROR=YTEST-PRED;
figure(4); hold on; plot(ERROR(ind),'g');

end