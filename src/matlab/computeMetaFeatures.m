% This function computes meta features from different subsets of columns in
% the core training file. The respective consecutive sets of columns and
% their types are described below for each one
function [metaFeats] = computeMetaFeatures(coreTable)

% Additional aggregate (meta) features obtained from:
% 1) lesion types: Sum from column NON_TARGET to ABDOMINAL
jj = find(strcmp(coreTable.Properties.VariableNames,'NON_TARGET'));
jj2 = find(strcmp(coreTable.Properties.VariableNames,'ABDOMINAL'));
lesionsTable = coreTable(:,jj:jj2);
totLesions = sum(strcmp('Y',table2cell(lesionsTable)),2);

% 2) Previous surgery cases: Sum from ORCHIDECTOMY to BILATERAL_ORCHIDECTOMY
jj = find(strcmp(coreTable.Properties.VariableNames,'ORCHIDECTOMY'));
jj2 = find(strcmp(coreTable.Properties.VariableNames,'BILATERAL_ORCHIDECTOMY'));
surgHistTable = coreTable(:,jj:jj2);
totSurgeries = sum(strcmp('Y',table2cell(surgHistTable)),2);

% 3) Prescribed medications: Sum from ANALGESICS to ANTI_ESTROGENS
jj = find(strcmp(coreTable.Properties.VariableNames,'ANALGESICS'));
jj2 = find(strcmp(coreTable.Properties.VariableNames,'ANTI_ESTROGENS'));
medsTable = coreTable(:,jj:jj2);
totMeds = sum(strcmp('YES',table2cell(medsTable)),2);

% 4) Indicated comorbidities: Sum from ARTTHROM to COPD
jj = find(strcmp(coreTable.Properties.VariableNames,'ARTTHROM'));
jj2 = find(strcmp(coreTable.Properties.VariableNames,'COPD'));
comorbTable = coreTable(:,jj:jj2);
totComorbs = sum(strcmp('Y',table2cell(comorbTable)),2);

% 5) Diseases in body systems: Sum from MHBLOOD to MHVASC (end)
jj = find(strcmp(coreTable.Properties.VariableNames,'MHBLOOD'));
jj2 = find(strcmp(coreTable.Properties.VariableNames,'MHVASC'));
disSysTable = coreTable(:,jj:jj2);
totDisSys = sum(strcmp('YES',table2cell(disSysTable)),2);

metaFeats = table(totLesions,totSurgeries,totMeds,totComorbs,totDisSys, ...
    'VariableNames',{'TOT_LES','TOT_SURG','TOT_MED','TOT_COMORB','TOT_DISSYS'});
