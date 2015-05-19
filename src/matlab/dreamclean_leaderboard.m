function [varIdx] = dreamclean_leaderboard()
%This puts the data into a nice parallelized fashion: No 'Y' and "Yes", for
%instance

%% Load data, define output structures
halabiTable = readtable('..\..\data\halabi_leader_rnd1_feats_table_5_14_15.csv'); 
load('../../data/halabi_22_feat_names.mat'); % loads f22_feat_names

varNames = halabiTable.Properties.VariableNames;
varNames = varNames( ~ismember( varNames, 'ECOG_C' ) );
varNames = [varNames, 'ECOG_C'];
f22_feat_names(ismember(f22_feat_names,'ECOG_C')) = [];
f22_feat_names = [f22_feat_names, 'ECOG_C'];

A = halabiTable(:, varNames);
B = array2table( nan(height(A), width(A)),  'VariableNames',A.Properties.VariableNames);

% Create a list of unprocessed variables
rawVars = B.Properties.VariableNames;


%% Process categorical columns
% STUDYID
studyClasses = unique(A.STUDYID);
classIdx = 1:numel(studyClasses);
B.STUDYID = 0*(B.STUDYID);
for j = classIdx
    B.STUDYID( ismember( A.STUDYID, studyClasses(j) ) ) = j;
end
rawVars( ismember( rawVars, 'STUDYID' ) ) = [];

% LKADT_P
B.LKADT_P = A.LKADT_P;
rawVars( ismember( rawVars, 'LKADT_P' ) ) = [];

% DEATH
B.DEATH = 0*(B.STUDYID);
B.DEATH( ismember( lower(A.DEATH), 'yes' ) ) = 1;
rawVars( ismember( rawVars, 'DEATH' ) ) = [];

% RACE_C
B.RACE_C = 1*(B.STUDYID);
B.RACE_C( ~ismember( lower(A.RACE_C), 'white') ) = 0;
rawVars( ismember( rawVars, 'RACE_C' ) ) = [];

% PRIOR_RADIOTHERAPY
B.PRIOR_RADIOTHERAPY = 0*(B.STUDYID);
B.PRIOR_RADIOTHERAPY( ismember( lower(A.PRIOR_RADIOTHERAPY), 'y') ) = 1;
rawVars( ismember( rawVars, 'PRIOR_RADIOTHERAPY' ) ) = [];

% ANALGESICS
B.ANALGESICS = 0*(B.STUDYID);
B.ANALGESICS( ismember( lower(A.ANALGESICS), 'yes') ) = 1;
rawVars( ismember( rawVars, 'ANALGESICS' ) ) = [];

% Other Y/N categoricals
catCols = halabiTable.Properties.VariableNames( 22:37 );

% Enjoy the ugly table indexing!!!
for i = 1:numel(catCols)
    i_Col = catCols(i);
    B.( i_Col{:} ) = 0*(B.STUDYID);
    B.( i_Col{:} )( ismember( lower(A{ :, i_Col }), 'y' ) ) = 1; 
    rawVars( ismember( rawVars, i_Col ) ) = [];
end


%% Verbatim copy of real-valued columns
B(:, rawVars) = A(:, rawVars);


%% Impute NaNs
% for i = 1:numel(B(1,:))
%     
%    if sum( isnan( B.(i) ) ) > 0
%       B.( i)( isnan( B.(i) ) ) = nanmean( B.( i ) );
%       disp(i);
%    end
%       
% end


%% Write to file
indNames = varNames( ~ismember( varNames, {'STUDYID', 'LKADT_P', 'DEATH'}));
indNames22 = f22_feat_names;
survName = {'LKADT_P'};
censorName = {'DEATH'};

ind_var   = table2array( B(:, indNames )   );
ind_var22 = table2array( B(:, indNames22 ) );
censoring = table2array( B(:, censorName ) );
surv_var  = table2array( B(:, survName)    );

ind_var_table = B(:,indNames);
ind_var22_table = B(:, indNames22 );
censoring_table = B(:, censorName ) ;
surv_var_table = B(:, survName);

save('../../data/cleaned_ind_leader_rnd1.mat', 'ind_var');
save('../../data/cleaned_censor_leader_rnd1.mat', 'censoring');
save('../../data/cleaned_surv_leader_rnd1.mat', 'surv_var');
save('../../data/cleaned_ind22_leader_rnd1.mat', 'ind_var22');

writetable(ind_var_table, '../../data/cleaned_ind_leader_rnd1.csv');
writetable(censoring_table, '../../data/cleaned_censor_leader_rnd1.csv');
writetable(surv_var_table, '../../data/cleaned_surv_leader_rnd1.csv');
writetable(ind_var22_table, '../../data/cleaned_ind22_leader_rnd1.csv');

