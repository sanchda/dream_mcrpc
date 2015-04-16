function [varIdx] = dreamclean()
%This puts the data into a nice parallelized fashion: No 'Y' and "Yes", for
%instance

%% Load data, define output structures
halabiTable = readtable('../../data/halabi_feats_table_4_9_15.csv'); 
load('../../data/halabi_22_feat_names.mat'); % loads f22_feat_names

% Move ECOG_C to the end of the data frame
varNames = halabiTable.Properties.VariableNames;
varNames = varNames( ~ismember( varNames, 'ECOG_C') );
varNames = [varNames, 'ECOG_C'];

A = halabiTable(:, varNames);
B = nan(height(A), width(A)+2);

% Prepare linear index for referencing into B (probably not needed, but
% whatever)
varIdx = array2table( 1:width(A) , 'VariableNames',A.Properties.VariableNames);

%% Process categorical columns
% STUDYID
i=1;
studyClasses = unique(A.STUDYID);
classIdx = 1:numel(studyClasses);
B(:,1) = 0;
for j = classIdx
    B(ismember( A.STUDYID, studyClasses(j)), 1) = j;
end

% LKADT_P
i=2;
B(:,i) = A.LKADT_P;

% DEATH
i = varIdx.DEATH;
i = 3; % Nope!
B(:, i) = 0;
B(ismember( A.DEATH, 'Yes'), i) = 1;

% RACE_C
i = varIdx.RACE_C;
i = 4; % Nope!
B(:, i) = 1;
B(~ismember(A.RACE_C, 'White'), i) = 0;

% PRIOR_RADIOTHERAPY
i = varIdx.PRIOR_RADIOTHERAPY;
i = 9; % Nope!
B(:, i) = 0;
B(ismember( A.PRIOR_RADIOTHERAPY, 'Y'), i) = 1;

% ANALGESICS
i = varIdx.ANALGESICS;
i = 10; % Nope!
B(:, i) = 0;
B(ismember( A.ANALGESICS, 'Y'), i) = 1;

% ECOG_C
B(:, 11) = A.ECOG_C;

% % ECOG_C, class 1
% unique_c = unique ( A.ECOG_C );
% i = varIdx.ECOG_C;
% i = 11; % Nope!
% B(:, i) = 0;
% B(ismember( A.ECOG_C, 0 ), i) = 1;
% 
% % ECOG_C, class 2
% i = 12; % Nope!
% B(:, i) = 0;
% B(ismember( A.ECOG_C, 1), i) = 1;
% 
% % ECOG_C, class 3
% i = 13; % Nope!
% B(:, i) = 0;
% B(ismember( A.ECOG_C, 2), i) = 1;

% ALB
B(: , 14) = A.ALB;

% ALP
B(:, 38) = A.TESTO;

% Other categoricals
theseColsB = 15:30;
theseColsA = A.Properties.VariableNames( (theseColsB) );
thisIdx = 1:numel(theseColsB);

for i = thisIdx
    i_B = theseColsB( i );
    i_A = theseColsA( i );
    B( :, i_B ) = 0;
    B( ismember( A{ :, i_A }, 'Y' ), i_B ) = 1;
end

%% Verbatim copy of real-valued columns
B(:,5:8) = A{:,5:8};

B(:,12:13) = A{:,12:13};

B(:,31:37) = A{:,31:37};

B(:,39:43) = A{:,39:43};


%% Impute NaNs
for i = 1:numel(B(1,:))
    
   if sum( isnan( B(:,i) ) ) > 0
      B(isnan( B(:,i)),i) = nanmean( B(:,i) );
      disp(i);
   end
      
end

%% Write to file
ind_var = B(:, [1 4:numel(B(1,:))] );
censoring = B(:, 3);
surv_var = B(:, 2);

save('../../data/cleaned_ind.mat', 'ind_var');
save('../../data/cleaned_censor.mat', 'censoring');
save('../../data/cleaned_surv.mat', 'surv_var');
