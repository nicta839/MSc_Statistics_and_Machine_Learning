%% This script will help you test out your kNN code

%% Select which data to use:

% 1 = dot cloud 1
% 2 = dot cloud 2
% 3 = dot cloud 3
% 4 = OCR data

dataSetNr = 2; % Change this to load new data 

% X - Data samples
% D - Desired output from classifier for each sample
% L - Labels for each sample
[X, D, L] = loadDataSet( dataSetNr );

% You can plot and study dataset 1 to 3 by running:
if dataSetNr < 4
    plotCase(X,D)
end
%% Select a subset of the training samples

numBins = 2;                    % Number of bins you want to devide your data into
numSamplesPerLabelPerBin = Inf; % Number of samples per label per bin, set to inf for max number (total number is numLabels*numSamplesPerBin)
selectAtRandom = true;          % true = select samples at random, false = select the first features

[XBins, DBins, LBins] = selectTrainingSamples(X, D, L, numSamplesPerLabelPerBin, numBins, selectAtRandom);

% Note: XBins, DBins, LBins will be cell arrays, to extract a single bin from them use e.g.
% XBin1 = XBins{1};
%
% Or use the combineBins helper function to combine several bins into one matrix (good for cross validataion)
% XBinComb = combineBins(XBins, [1,2,3]);

% Add your own code to setup data for training and test here
XTrain = XBins{1};
LTrain = LBins{1};
XTest  = XBins{2};
LTest  = LBins{2};

%% Use kNN to classify data
%  Note: you have to modify the kNN() function yourself.

% Find optimal k for given dataset
K = 50;
nbrTrainData = length(XTrain);
folds = 10;
while ~mod(nbrTrainData, folds) == 0
    folds = folds - 1;
end

accuracies = zeros(folds, K); 
foldSize = length(XTrain) / folds;

% By shuffling the rows we are trying to prevent that folds only contain one Label
shuffleRows = randperm(length(XTrain)); 
XTrain = XTrain(shuffleRows,:);
LTrain = LTrain(shuffleRows);


for k = 1:K
    for fold = 1:folds
        % Setting range for test fold
        rangeR = fold * foldSize;
        rangeL = rangeR - foldSize + 1;
        
        % Slicing train and test data for each iteration
        trainData = XTrain;
        trainLabel = LTrain;
        trainData(rangeL:rangeR,:) = [];
        trainLabel(rangeL:rangeR,:) = [];
        testLabel = LTrain(rangeL:rangeR,:);
        testData = XTrain(rangeL:rangeR,:);
        
        % Performing kNN for each k and each fold
        predictions = kNN(testData, k, trainData, trainLabel);    
        
        % Evaluation of fold for given k
        cm = calcConfusionMatrix(predictions, testLabel);
        accuracies(fold, k) = calcAccuracy(cm);
    end
end

% Calculate average accuracy for each k considering all folds
% Find the smallest k with the highest average accuracy
avgAccuracies = transpose(mean(accuracies)); 
bestAccuraciesInd = find(avgAccuracies == max(avgAccuracies(:)));
optK = bestAccuraciesInd(1);

% Classify test data
LPredTrain  = kNN(XTrain , optK, XTrain, LTrain);

LPredTest  = kNN(XTest , optK, XTrain, LTrain);

%% Calculate The Confusion Matrix and the Accuracy
%  Note: you have to modify the calcConfusionMatrix() and calcAccuracy()
%  functions yourself.

% The confucionMatrix
cM = calcConfusionMatrix(LPredTest, LTest);

% The accuracy
acc = calcAccuracy(cM);

%% Plot classifications
%  Note: You should not have to modify this code

if dataSetNr < 4
    plotResultDots(XTrain, LTrain, LPredTrain, XTest, LTest, LPredTest, 'kNN', [], k);
else
    plotResultsOCR(XTest, LTest, LPredTest)
end
