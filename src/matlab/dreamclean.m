function [varIdx] = dreamclean()
%This puts the data into a nice parallelized fashion: No 'Y' and "Yes", for
%instance

%% Load data, define output structures
halabiTable = readtable('../../data/halabi_feats_table_4_9_15.csv'); 
load('../../data/halabi_22_feat_names.mat'); % loads f22_feat_names

varNames = halabiTable.Properties.VariableNames;
varNames = varNames( ~ismember( varNames, 'ECOG_C' ) );
varNames = [varNames, 'ECOG_C'];

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
B.DEATH( ismember( A.DEATH, 'Yes' ) ) = 1;
rawVars( ismember( rawVars, 'DEATH' ) ) = [];

% RACE_C
B.RACE_C = 1*(B.STUDYID);
B.RACE_C( ~ismember( A.RACE_C, 'White') ) = 0;
rawVars( ismember( rawVars, 'RACE_C' ) ) = [];

% PRIOR_RADIOTHERAPY
B.PRIOR_RADIOTHERAPY = 0*(B.STUDYID);
B.PRIOR_RADIOTHERAPY( ismember( A.PRIOR_RADIOTHERAPY, 'Y') ) = 1;
rawVars( ismember( rawVars, 'PRIOR_RADIOTHERAPY' ) ) = [];

% ANALGESICS
B.ANALGESICS = 0*(B.STUDYID);
B.ANALGESICS( ismember( A.ANALGESICS, 'Y') ) = 1;
rawVars( ismember( rawVars, 'ANALGESICS' ) ) = [];

% Other Y/N categoricals
catCols = halabiTable.Properties.VariableNames( 15:30 );

% Enjoy the ugly table indexing!!!
for i = 1:numel(catCols)
    i_Col = catCols(i);
    B.( i_Col{:} ) = 0*(B.STUDYID);
    B.( i_Col{:} )( ismember( A{ :, i_Col }, 'Y' ) ) = 1; 
    rawVars( ismember( rawVars, i_Col ) ) = [];
end


%% Verbatim copy of real-valued columns
B(:, rawVars) = A(:, rawVars);


%% Impute NaNs
for i = 1:numel(B(1,:))
    
   if sum( isnan( B.(i) ) ) > 0
      B.( i)( isnan( B.(i) ) ) = nanmean( B.( i ) );
      disp(i);
   end
      
end


%% Write to file
indNames = varNames( ~ismember( varNames, {'STUDYID', 'LKADT_P', 'DEATH'}));
indNames22 = f22_feat_names;
survName = {'LKADT_P'};
censorName = {'DEATH'};

ind_var   = table2array( B(:, indNames )   );
ind_var22 = table2array( B(:, indNames22 ) );
censoring = table2array( B(:, censorName ) );
surv_var  = table2array( B(:, survName)    );

save('../../data/cleaned_ind.mat', 'ind_var');
save('../../data/cleaned_censor.mat', 'censoring');
save('../../data/cleaned_surv.mat', 'surv_var');
save('../../data/cleaned_ind22.mat', 'ind_var22');
