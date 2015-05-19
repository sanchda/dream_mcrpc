function [] = prepare_save_HalabiData()

% Obtain the initial set of 22 features
featNames = {'RPT','LKADT_P','DEATH','RACE_C','AGEGRP','BMI',...
    'HEIGHTBL','WEIGHTBL','PRIOR_RADIOTHERAPY','ANALGESICS','ECOG_C',...
    'GLEAS_DX','ALB','NON_TARGET','TARGET','BONE','RECTAL',...
    'LYMPH_NODES','KIDNEYS','LUNGS','LIVER','PLEURA','PROSTATE','ADRENAL',...
    'BLADDER','PERITONEUM','COLON','SOFT_TISSUE','ABDOMINAL','LDH','WBC',...
    'AST','TBILI','PLT','HB','ALT','TESTO','PSA','ALP'};

% fname = '..\..\data\CoreTable_training_22_feats_Halabi.csv';
fname = '..\..\data\prostate_cancer_challenge_data_leaderboard\CoreTable_leaderboard_v1.0_age_wt_ht.csv';
coreTable = readtable(fname,'TreatAsEmpty',{'','.','""'});
halabiTable = coreTable( :, ismember(coreTable.Properties.VariableNames, featNames ) );

%% Calculate Charlson comorbidity index based on available comorbidity types
tumorCols = {'BONE','RECTAL','LYMPH_NODES','KIDNEYS','LUNGS','LIVER','PLEURA',...
    'PROSTATE','ADRENAL','BLADDER','PERITONEUM','COLON','SOFT_TISSUE','ABDOMINAL'};
% tumorIndx = zeros(length(tumorCols),1);
% 
% for i=1:length(tumorCols),
%     tumorIndx(i) = find(strcmp(coreTable.Properties.VariableNames,tumorCols{i}));
% end

charlson_score = strcmp('Y',coreTable.CEREBACC)*1 + strcmp('Y',coreTable.CHF)*1 + ...
    strcmp('Y',coreTable.DVT)*1 + strcmp('Y',coreTable.DIAB)*1 + strcmp('Y',coreTable.MI)*1 + ...
    strcmp('Y',coreTable.PUD)*1 + strcmp('Y',coreTable.COPD)*1 + ...
    (sum(strcmp('Y',table2array(coreTable(:,tumorCols))),2)>0)*6; % tumorCols works, tumorIndx not needed
halabiTable.CHARLSON = charlson_score;


%% Calculate the DISEASE_SITE variable
% Lymph node only = 1, Bone = 2, Visceral = 3, None = 0
viscCols = tumorCols;
viscCols([1 3]) = [];
halabiTable.DISEASE_SITE = strcmp('Y',halabiTable.LYMPH_NODES) + strcmp('Y',halabiTable.BONE) + ...
    (sum(strcmp('Y',table2array(halabiTable(:,viscCols))),2)>0)*1;


%% Calculate liver_or_lung variable
halabiTable.LIV_OR_LUNG = strcmp('Y',halabiTable.LIVER) | strcmp('Y',halabiTable.LUNGS);


%% Calculate LDH_ULN variable
halabiTable.LDH_1ULN = halabiTable.LDH > 280;


%% Save the results
all_featNames = halabiTable.Properties.VariableNames;
halabi_feat_names = {'RACE_C','AGEGRP','BMI','PRIOR_RADIOTHERAPY','ANALGESICS','ECOG_C',...
    'CHARLSON','GLEAS_DX','ALB','DISEASE_SITE','LIV_OR_LUNG','LDH_1ULN','WBC',...
    'AST','TBILI','PLT','HB','ALT','TESTO','PSA','ALP'};
f22_feat_names = all_featNames(ismember(halabiTable.Properties.VariableNames, halabi_feat_names ));

% outfname = '..\..\data\halabi_feats_table.mat';
outfname = '..\..\data\halabi_leader_rnd1_feats_table_5_14_15.mat';
save(outfname, 'halabiTable', 'all_featNames', 'f22_feat_names');
% outfname2 = '..\..\data\halabi_feats_table_4_9_15.csv';
outfname2 = '..\..\data\halabi_leader_rnd1_feats_table_5_14_15.csv';
writetable(halabiTable, outfname2);
% save('..\..\data\halabi_22_feat_names.mat','f22_feat_names');

% % Save the 21 features along with the survival time and the cencorship to a
% % separate file
% halabi22feats = halabiTable(:,f22_feat_names);
% halabi22feats.SURV_TIME = halabiTable.LKADT_P;
% halabi22feats.DEATH = halabiTable.DEATH;
% writetable(halabi22feats,'..\..\data\halabi_22_feats_4_15_15.csv');
