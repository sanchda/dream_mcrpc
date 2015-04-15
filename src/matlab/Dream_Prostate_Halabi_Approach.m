function [] = Dream_Prostate_Halabi_Approach()

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


halabiTable.TOT_COMORB = [];
halabiTable.CHARLSON =  charlson_score;


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
f22_feat_names = {'RACE_C','AGEGRP','BMI','PRIOR_RADIOTHERAPY','ANALGESICS','ECOG_C',...
    'CHARLSON','GLEAS_DX','ALB','DISEASE_SITE','LIV_OR_LUNG','LDH_1ULN','WBC',...
    'AST','TBILI','PLT','HB','ALT','TESTO','PSA','ALP'};
all_featNames = halabiTable.Properties.VariableNames;

save('..\..\data\halabi_feats_table.mat', 'halabiTable', 'all_featNames', 'f22_feat_names');
save('..\..\data\halabi_22_feat_names.mat','f22_feat_names');
writetable(halabiTable, '..\..\data\halabi_feats_table_4_9_15.csv');

%% Process the Halabi data into a matrix fit for consumption

