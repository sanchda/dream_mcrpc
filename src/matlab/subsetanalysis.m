%First order of business: create a vector that contains all binary lists of
%length n

warning('off','all')
%How many variables?
lengo = 23;

X = dec2bin(0:2^lengo-1);

X=X-'0';




% [B,dev,stats]  = mnrfit([2,3,2,1,3],[1,2,1,1,2]);
% Z = glmfit([2,3,2,1,3],[1,2,1,1,2],'binomial','logit');




J = rand(100,23);
response = binornd(1,.5,[100,1])+1;


%Restricting our set to the 22 variables as discussed in the Halabi paper,
%with associated cleaning involved



%Restricting to those which are noncencored; and ridding all columns that
%don't have anything to do with our predictions.

C = B(find(B(:,3) == 1),:);
C = C(:,[2,4:6,9:16,34:45]);


input = C(:,2:24);
output = C(:,1);


ansvec = [0,0];
maxo = 0;
tic
 for i = 104511:4*10^6
    
    q = find(X(i,:) == 1);
    M  = fitlm(C(:,q),output);
    s = M.Rsquared.Adjusted;
    
    if s> maxo && s<.75
        maxo = s;
        ansvec = [s,X(i,:)];
    end
        
    
    
    
 end

 
 
 ansvec
 
toc  
    
    
    




