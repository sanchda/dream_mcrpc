function [] = plotPairwiseScatters(dataMat, varNames, titStr)


figure
nVars = length(varNames);
for i=1:nVars,
    h = subplot(nVars,nVars,(i-1)*nVars+i);
%     axes(h);    axes('Visible','off');    
    text(0,0.5,varNames(i),'FontUnits','normalized');
    axis tight; axis off;
end

for i=1:nVars,
    for j=i+1:nVars,
        subplot(nVars,nVars,(i-1)*nVars+j);
        plot(dataMat(:,i),dataMat(:,j),'.');
    end
end

subplot(nVars,nVars,[(nVars-1)*nVars+1, (nVars-1)*nVars+1]);
text(0,0.5,strcat('Study id: ' , titStr),'FontSize',12,'FontUnits','normalized');
axis tight; axis off;
 