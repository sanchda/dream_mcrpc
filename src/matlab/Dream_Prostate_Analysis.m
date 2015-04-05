function [] = Dream_Prostate_Analysis()

% coreTable = readtable('..\Data\CoreTable_training.csv','TreatAsEmpty',{'','.','""'});

%% First subtable obtained from the features that Halabi etal. used in the Nomogram (Figure 2)
% subTable = table(coreTable.STUDYID, coreTable.LKADT_P, coreTable.LDH, coreTable.ECOG_C, ...
%     coreTable.ALB, coreTable.ALP, coreTable.HB, coreTable.PSA, 'VariableNames',{'STUDYID','LKADT_P','LDH','ECOG_C','ALB','ALP','HB','PSA'});
% 
% uStdy = unique(subTable.STUDYID);
% study1Table = subTable(strcmp(subTable.STUDYID,uStdy{1}),2:end);
% study2Table = subTable(strcmp(subTable.STUDYID,uStdy{2}),2:end);
% study3Table = subTable(strcmp(subTable.STUDYID,uStdy{3}),2:end);

% Load 'coreTable', 'subTable', 'coreTable2','subTable2','study1Table',
% 'study2Table','study3Table','uStdy'
load('..\Data\matlab_vars_4_2_15.mat');

% Obtain respective patient records for each of the 3 study ids
study1Mat = table2array(study1Table); % ASCENT2
study2Mat = table2array(study2Table); % CELGENE
study3Mat = table2array(study3Table); % EFC6546

% % Calculate the minimum, maximum and mean values and correlation matrices
[minVals1, meanVals1, maxVals1, corrMat1] = findDescriptives(study1Mat, -1);
[minVals2, meanVals2, maxVals2, corrMat2] = findDescriptives(study2Mat, -1);
[minVals3, meanVals3, maxVals3, corrMat3] = findDescriptives(study3Mat, -1);

varNames = subTable.Properties.VariableNames(2:end);
plotPairwiseScatters(study1Mat, varNames, uStdy(1));
plotPairwiseScatters(study2Mat, varNames, uStdy(2));
plotPairwiseScatters(study3Mat, varNames, uStdy(3));

%
%% Additional aggregate (meta) features obtained from:
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
%% Append meta features to the end of the core table and save into new csv 
coreTable2 = [coreTable metaFeats];
subTable2 = [subTable metaFeats];

writetable(coreTable2,'..\Data\CoreTable_training_4_2_15.csv');
save('..\Data\matlab_vars_4_2_15.mat','coreTable', 'subTable', 'coreTable2',...
    'subTable2','study1Table','study2Table','study3Table','uStdy');
