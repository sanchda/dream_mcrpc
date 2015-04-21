library('data.table');
library('class');
library('boot');
library('car');
library('mi');
library('mice');
library('e1071')
library('rpart')
library('missForest')
# Change this
dataDir = "C:\\AKA@Geisinger\\Projects\\AML Challenge\\prostate_cancer\\dream_mcrpc-master\\data\\";
setwd(dataDir);
dataFile = "halabi_feats_table_4_9_15_v1.0.csv";
trainingTable = fread(dataFile);

#setkey(trainingTable);
trainingFrame = as.data.table(trainingTable);

info <- mi.info(trainingFrame);
results.imp <- mi(trainingFrame);
results.mi <- mi(trainingFrame,info, rand.imp.method = "bootstrap", run.past.convergence = FALSE, seed = NA, check.coef.convergence = FALSE, add.noise = noise.control())
com <-complete(results.mi);
write.csv(com, file = "halabi_43feature_data_mi_imputed_v1.0.csv");
training.mis <- missForest(trainingFrame,verbos=TRUE);
com <-complete(results.miss);
write.csv(com, file = "halabi_43feature_data_missForest_imputed_v1.0.csv");
