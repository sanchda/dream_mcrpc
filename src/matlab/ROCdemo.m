function [TESTav,PREDav,PRED,YTEST]=ROCdemo
close all
% get variables

% Unfortunately, variables 
load dreamdata
INPUTS=B(:,5:end); % has missing entries!
OUTreal=B(:,2); % survival days
OUTbin=B(:,3); % 1=dead, 0=alive  % has missing entries!
% drop features with many missing entries, unimportant for now
INPUTS(:,[11,29,36,12])=[];
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

% define a bunch of outputs from OUTreal and OUTbin: we project from day 0
% to day 1000
DEAD=zeros(1600,1000);
for i=1:1600
	for j=1:1000
		if OUTreal(i)>=j
			DEAD(i,j)=1; % ok, 1=dead
		end
	end
end	
% then we would need to cycle from 1 to M days to define output.

% PCA and PREDICTION begin
% work with 'how many days' output only

% define training set, the rest goes into testing set
TEMPX=INPUTS; TEMPY=DEAD;

M=1000;
ind=randsample(1:1600,M);

% 
XTRAIN=TEMPX(ind,:); YTRAIN=DEAD(ind,:);
TEMPX(ind,:)=[]; TEMPY(ind,:)=[];
XTEST=TEMPX; YTEST=TEMPY;
clear TEMPX
clear TEMPY


% no weighting in this version! Add later maybe
N=37;
METRIC=eye(N);
WEIGHTS=eye(M);
% that was for testing only

C=XTRAIN'*WEIGHTS*XTRAIN;

[evector,evalue]=eig(METRIC*C,'nobalance');
evalue=diag(evalue);
[esorted,ind_esorted]=sort(abs(evalue),'descend');
esorted=real(esorted); % smaller eigenvalues can have imaginary numerical noise
figure(1); plot(log(esorted)/log(10),'r*-');

% this is a good place to define k
total_energy=sum(esorted);
partial_energy=0;
for k=1:N
	partial_energy=partial_energy+esorted(k)/total_energy;
	if partial_energy>0.999999
		break
	end
end
disp('Sufficient (recommended) k is'); disp(k); % we get 5 to 8

% % or ignore all this and use default k
k=5;

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

% now we need predictions of survival for days from 1 to 1000
PRED=zeros(size(YTEST));
for i=1:1000
    disp(i);
	TRAIN_OUT=YTRAIN(:,i);
	TEST_OUT=YTEST(:,i);
	B = mnrfit(RED_TRAIN,TRAIN_OUT+1);
	ypred=mnrval(B,RED_TEST);
	PRED(:,i)=ypred(:,2);
end
	
% some rounding up with TR=0.6;
TR=0.5;
YPRED=zeros(size(YTEST));
for i=1:1600-M
    for j=1:1000
        if PRED(i,j)>TR
            YPRED(i,j)=1;
        end
    end
end

% some averaging
TESTav=zeros(1,1000);
PREDav=zeros(1,1000);
for i=1:1000
    TESTav(i)=mean(YTEST(:,i));
    PREDav(i)=mean(YPRED(:,i));
end

% graph? Graph!
 figure(2); hold on; plot(TESTav,'k'); plot(PREDav,'r');

end