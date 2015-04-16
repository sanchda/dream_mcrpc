function [] = Dream_Prostate_Halabi_Approach()

presaved = 1; % Flag indicating that we already obtained the Halabi data

% Obtain the features they mention in Halabi paper and save the
% intermediate files
if ~presaved
    extract_save_HalabiData();
end

% halabi22feats = readtable('..\..\data\halabi_22_feats_4_15_15.csv');
% halabiTable = readtable('..\..\data\halabi_feats_table_4_9_15.csv');
load('../../data/halabi_22_feat_names.mat'); % loads f22_feat_names
varIdx = dreamclean();
idx = varIdx(:,f22_feat_names);
load('..\..\data\cleaned_ind.mat'); % loads ind_var
load('..\..\data/cleaned_censor.mat'); % loads censoring
load('..\..\data/cleaned_surv.mat');  % load surv_var

ind_var_22 = ind_var(:,[1,table2array(idx(1,:))-2]);

%% Run cox proportional hazards model
[b,logl,H,stats] = coxphfit(ind_var,surv_var,'censoring',censoring,'baseline',0);
% Dream_Cox_Surv(X, SurvTime, Censor)
