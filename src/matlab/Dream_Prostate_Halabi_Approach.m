function [] = Dream_Prostate_Halabi_Approach()

presaved = 1; % Flag indicating that we already obtained the Halabi data

% Obtain the features they mention in Halabi paper and save the
% intermediate files
if ~presaved
    extract_save_HalabiData();
end

halabiTable = readtable('..\..\data\halabi_22_feats_4_14_15.csv');






