function [] = Dream_Prostate_Halabi_Approach()

presaved = 1; % Flag indicating that we already obtained the Halabi data

% Obtain the features they mention in Halabi paper and save the
% intermediate files
if ~presaved
    extract_save_HalabiData();
end

halabi22feats = readtable('..\..\data\halabi_22_feats_4_15_15.csv');

%% Run cox proportional hazards model
n = height(halabi22feats);
tmpCol = ones(n,1);
tmpCol(strcmp(halabi22feats.RACE_C,'White')) = 0;
halabi22feats.RACE_C = tmpCol;
tmpCol = zeros(n,1);
tmpCol(strcmp(halabi22feats.PRIOR_RADIOTHERAPY,'Y')) = 1;
halabi22feats.PRIOR_RADIOTHERAPY = tmpCol;
tmpCol = zeros(n,1);
tmpCol(strcmp(halabi22feats.ANALGESICS,'YES')) = 1;
halabi22feats.ANALGESICS = tmpCol;
tmpCol = zeros(n,1);
tmpCol(strcmp(halabi22feats.DEATH,'YES')) = 1;
halabi22feats.DEATH = tmpCol;
X = table2array(halabi22feats(:,1:21));
SurvTime = halabi22feats.SURV_TIME;
Censor = ones(n,1)-halabi22feats.DEATH;
[b,logl,H,stats] = coxphfit(X,SurvTime,'censoring',Censor,'baseline',0);





