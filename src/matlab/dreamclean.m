%This puts the data into a nice parallelized fashion: No 'Y' and "Yes", for
%instance

%Load the file halabi_22_feature_data.csv

halabiTable = readtable('../../data/halabi_feats_table_4_9_15.csv'); 
load('../../data/halabi_22_feat_names.mat')

A = halabiTable;
B = nan(height(A), width(A)+2);

% Prepare linear index for referencing into B (probably not needed, but
% whatever)
varIdx = array2table( 1:width(A) , 'VariableNames',A.Properties.VariableNames);

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

% ECOG_C, class 1
unique_c = unique ( A.ECOG_C );
i = varIdx.ECOG_C;
i = 11; % Nope!
B(:, i) = 0;
B(ismember( A.ECOG_C, 0 ), i) = 1;

% ECOG_C, class 2
i = 12; % Nope!
B(:, i) = 0;
B(ismember( A.ECOG_C, 1), i) = 1;

% ECOG_C, class 3
i = 13; % Nope!
B(:, i) = 0;
B(ismember( A.ECOG_C, 2), i) = 1;

% ALB
B( ~ismember(A.ALB, 'NaN'), 16) = str2double( A.ALB( ~ismember( A.ALB, 'NaN')));

% ALP
B( ~ismember(A.ALP, 'NaN'), 40) = str2double( A.ALP( ~ismember( A.ALP, 'NaN')));

% Other categoricals
theseColsB = 17:32;
theseColsA = A.Properties.VariableNames( (theseColsB) - 2 );
thisIdx = 1:numel(theseColsB);

for i = thisIdx
    i_B = theseColsB( i );
    i_A = theseColsA( i );
    B( :, i_B ) = 0;
    B( ismember( A{ :, i_A }, 'Y' ), i_B ) = 1;
end




% THIS IS A HUGE QUESTION MARK
% TODO: FIX

B(:,5:8) = A{:,5:8};

B(:,14:15) = A{:,12:13};

B(:,33:39) = A{:,31:37};

B(:,41:45) = A{:,39:43};