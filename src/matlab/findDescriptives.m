function [minVals, meanVals, maxVals, corrMat] = findDescriptives(dataMat, repNAN)

in = isnan(dataMat);    % Find NaN values
tDataMat = dataMat;
minVals = min(tDataMat);
meanVals = mean(tDataMat);
maxVals = max(tDataMat);
tDataMat(in) = repNAN;  % Replace NaNs for correlation calculation
corrMat = corrcoef(tDataMat);
