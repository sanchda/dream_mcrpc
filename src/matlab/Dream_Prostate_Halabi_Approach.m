function [] = Dream_Prostate_Halabi_Approach

% Obtain the initial set of 22 features
featNames = {'STUDYID','LKADT_P','DEATH','RACE_C','AGEGRP','BMI',...
    'HEIGHTBL','WEIGHTBL','PRIOR_RADIOTHERAPY','ANALGESICS','ECOG_C',...
    'TOT_COMORB','GLEAS_DX','ALB','NON_TARGET','TARGET','BONE','RECTAL',...
    'LYMPH_NODES','KIDNEYS','LUNGS','LIVER','PLEURA','PROSTATE','ADRENAL',...
    'BLADDER','PERITONEUM','COLON','SOFT_TISSUE','ABDOMINAL','LDH','WBC',...
    'AST','TBILI','PLT','HB','ALT','TESTO','PSA','ALP'};

coreTable = readtable('..\..\data\CoreTable_training_22_feats_Halabi.csv','TreatAsEmpty',{'','.','""'});
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

halabiTable.TOT_COMORB = charlson_score;
tin = find(strcmp(halabiTable.Properties.VariableNames,'TOT_COMORB'));
halabiTable.Properties.VariableNames{tin} = 'CHARLSON';
tin = find(strcmp('TOT_COMORB',featNames));
featNames{tin} = 'CHARLSON';

%% Calculate the DISEASE_SITE variable
% Lymph node only = 1, Bone = 2, Visceral = 3, None = 0
viscCols = tumorCols;
viscCols(3) = [];
viscCols(1) = [];
dis_site = strcmp('Y',halabiTable.LYMPH_NODES) + strcmp('Y',halabiTable.BONE) + ...
    (sum(strcmp('Y',table2array(halabiTable(:,viscCols))),2)>0)*1;
halabiTable.DISEASE_SITE = dis_site;
featNames{end+1} = 'DISEASE_SITE';

%% Calculate liver_or_lung variable
liv_or_lung = strcmp('Y',halabiTable.LIVER) | strcmp('Y',halabiTable.LUNGS);
halabiTable.LIV_OR_LUNG = liv_or_lung;
featNames{end+1} = 'LIV_OR_LUNG';

%% Calculate LDH_ULN variable
ldh_uln = halabiTable.LDH > 280;
halabiTable.LDH_1ULN = ldh_uln;
featNames{end+1} = 'LDH_1ULN';

%% Save the results
f22_feat_names = {'RACE_C','AGEGRP','BMI','PRIOR_RADIOTHERAPY','ANALGESICS','ECOG_C',...
    'CHARLSON','GLEAS_DX','ALB','DISEASE_SITE','LIV_OR_LUNG','LDH_1ULN','WBC',...
    'AST','TBILI','PLT','HB','ALT','TESTO','PSA','ALP'};
all_featNames = featNames;

save('..\..\data\halabi_feats_table.mat', 'halabiTable', 'all_featNames', 'f22_feat_names');
save('..\..\data\halabi_22_feat_names.mat','f22_feat_names');
writetable(halabiTable, '..\..\data\halabi_feats_table_4_9_15.csv');

tt=1;