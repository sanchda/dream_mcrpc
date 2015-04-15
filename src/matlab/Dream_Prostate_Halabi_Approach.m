function [] = Dream_Prostate_Halabi_Approach()

presaved = 1; % Flag indicating that we already obtained the Halabi data

% Obtain the features they mention in Halabi paper and save the
% intermediate files
if ~presaved
    extract_save_HalabiData();
end

halabiTable = readtable('..\..\data\halabi_22_feats_4_14_15.csv');

tt=1;


<<<<<<< HEAD
halabiTable.TOT_COMORB = [];
halabiTable.CHARLSON =  charlson_score;
=======
>>>>>>> origin/master



<<<<<<< HEAD

%% Calculate liver_or_lung variable
halabiTable.LIV_OR_LUNG = strcmp('Y',halabiTable.LIVER) | strcmp('Y',halabiTable.LUNGS);


%% Calculate LDH_ULN variable
halabiTable.LDH_1ULN = halabiTable.LDH > 280;


%% Save the results
f22_feat_names = {'RACE_C','AGEGRP','BMI','PRIOR_RADIOTHERAPY','ANALGESICS','ECOG_C',...
    'CHARLSON','GLEAS_DX','ALB','DISEASE_SITE','LIV_OR_LUNG','LDH_1ULN','WBC',...
    'AST','TBILI','PLT','HB','ALT','TESTO','PSA','ALP'};
all_featNames = halabiTable.Properties.VariableNames;

save('..\..\data\halabi_feats_table.mat', 'halabiTable', 'all_featNames', 'f22_feat_names');
save('..\..\data\halabi_22_feat_names.mat','f22_feat_names');
writetable(halabiTable, '..\..\data\halabi_feats_table_4_9_15.csv');

%% Process the Halabi data into a matrix fit for consumption

=======
>>>>>>> origin/master
