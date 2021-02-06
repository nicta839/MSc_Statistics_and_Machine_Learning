function [ cM ] = calcConfusionMatrix( LPred, LTrue )
% CALCCONFUSIONMATRIX returns the confusion matrix of the predicted labels

classes  = unique(LTrue);
NClasses = length(classes);

% Add your own code here
cM = zeros(NClasses);

for i = 1:size(LTrue)
    x = LPred(i);
    y = LTrue(i);
    cM(x,y) = cM(x,y) + 1;
end
cM;

end

