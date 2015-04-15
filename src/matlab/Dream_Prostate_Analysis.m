function [] = Dream_Prostate_Analysis()

preLoaded = 1;

if ~preLoaded
    coreTable = readtable('..\..\data\CoreTable_training_4_2_15.csv','TreatAsEmpty',{'','.','""'});

    %% First subtable obtained from the features that Halabi etal. used in the Nomogram (Figure 2)
    subTable = coreTable(:, {'STUDYID', 'LKADT_P', 'LDH', 'ECOG_C', 'ALB', 'ALP', 'HB', 'PSA'});
    subTable.Properties.VariableNames = {'STUDYID','LKADT_P','LDH','ECOG_C','ALB','ALP','HB','PSA'};

    uStdy = unique(subTable.STUDYID);
    study1Table = subTable(ismember(subTable.STUDYID,uStdy{1}),2:end);
    study2Table = subTable(ismember(subTable.STUDYID,uStdy{2}),2:end);
    study3Table = subTable(ismember(subTable.STUDYID,uStdy{3}),2:end);
else
    % Load 'coreTable', 'subTable', 'coreTable2','subTable2','study1Table',
    % 'study2Table','study3Table','uStdy'
    load('..\..\data\matlab_vars_4_2_15.mat');
end

% Obtain respective patient records for each of the 3 study ids
study1Mat = table2array(study1Table); % ASCENT2
study2Mat = table2array(study2Table); % CELGENE
study3Mat = table2array(study3Table); % EFC6546

% % Calculate the minimum, maximum and mean values and correlation matrices
% NaN values need to be replaced with something for calculating mean and corralation
repVal = -1; 
[minVals1, meanVals1, maxVals1, corrMat1] = findDescriptives(study1Mat, repVal);
[minVals2, meanVals2, maxVals2, corrMat2] = findDescriptives(study2Mat, repVal);
[minVals3, meanVals3, maxVals3, corrMat3] = findDescriptives(study3Mat, repVal);

save('..\..\results\descriptives_4_2_15.mat', 'minVals*', 'meanVals*', 'maxVals*','corrMat*');

% Display pairwise feature scatter plots for each Study type
varNames = subTable.Properties.VariableNames(2:end);
plotPairwiseScatters(study1Mat, varNames, uStdy(1)); % ASCENT2
plotPairwiseScatters(study2Mat, varNames, uStdy(2)); % CELGENE
plotPairwiseScatters(study3Mat, varNames, uStdy(3)); % EFC6546


%% Obtain meta features from the core training table
metaFeats = computeMetaFeatures(coreTable);


%% Append meta features to the end of the core table and save into new csv 
coreTable2 = [coreTable metaFeats];
subTable2 = [subTable metaFeats];
writetable(coreTable2,'..\..\data\CoreTable_training_4_2_15.csv');
save('..\..\data\matlab_vars_4_2_15.mat','coreTable', 'subTable', 'coreTable2',...
    'subTable2','study1Table','study2Table','study3Table','uStdy');
