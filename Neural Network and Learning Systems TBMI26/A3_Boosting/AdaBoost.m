%% Seed
rng('default');
rng(1);

%% Hyper-parameters

% Number of randomized Haar-features
nbrHaarFeatures = 100;
% Number of training images, will be evenly split between faces and
% non-faces. (Should be even.)
nbrTrainImages = 1000;
% Number of weak classifiers
nbrWeakClassifiers = 100;

%% Load face and non-face data and plot a few examples
load faces;
load nonfaces;
faces = double(faces(:,:,randperm(size(faces,3))));
nonfaces = double(nonfaces(:,:,randperm(size(nonfaces,3))));

figure(1);
colormap gray;
for k=1:25
    subplot(5,5,k), imagesc(faces(:,:,10*k));
    axis image;
    axis off;
end

figure(2);
colormap gray;
for k=1:25
    subplot(5,5,k), imagesc(nonfaces(:,:,10*k));
    axis image;
    axis off;
end

%% Generate Haar feature masks
haarFeatureMasks = GenerateHaarFeatureMasks(nbrHaarFeatures);

figure(3);
colormap gray;
for k = 1:25
    subplot(5,5,k),imagesc(haarFeatureMasks(:,:,k),[-1 2]);
    axis image;
    axis off;
end

%% Create image sets (do not modify!)

% Create a training data set with examples from both classes.
% Non-faces = class label y=-1, faces = class label y=1
trainImages = cat(3,faces(:,:,1:nbrTrainImages/2),nonfaces(:,:,1:nbrTrainImages/2));
xTrain = ExtractHaarFeatures(trainImages,haarFeatureMasks);
yTrain = [ones(1,nbrTrainImages/2), -ones(1,nbrTrainImages/2)];

% Create a test data set, using the rest of the faces and non-faces.
testImages  = cat(3,faces(:,:,(nbrTrainImages/2+1):end),...
                    nonfaces(:,:,(nbrTrainImages/2+1):end));
xTest = ExtractHaarFeatures(testImages,haarFeatureMasks);
yTest = [ones(1,size(faces,3)-nbrTrainImages/2), -ones(1,size(nonfaces,3)-nbrTrainImages/2)];

% Variable for the number of test-data.
nbrTestImages = length(yTest);

%% Implement the AdaBoost training here
%  Use your implementation of WeakClassifier and WeakClassifierError
weights(1:nbrTrainImages, 1) = 1/nbrTrainImages; % Initialize weights
results = zeros(nbrWeakClassifiers,4);

for t = 1:nbrWeakClassifiers
    eps_min = Inf;
    feat_min = 0;
    thresh_min = 0;
    pol_min = 0;
    alpha_min = 0;
    h_min = 0;
    for feature = 1:nbrHaarFeatures
        thresholds = unique(xTrain(feature,:));
        for threshold = thresholds
            polarity = 1;
            h_x = WeakClassifier(threshold, polarity, xTrain(feature,:));
            eps = WeakClassifierError(h_x, weights, yTrain);
            if eps > 0.5
                eps = 1-eps;
                polarity = -polarity;
            end
            if eps < eps_min
                eps_min = eps;
                alpha_min = (1/2) * log((1-eps_min) / eps_min);
                
                feat_min = feature;
                thresh_min = threshold;
                pol_min = polarity;
                h_min = pol_min * h_x;
            end    
        end
    end
    
    weights = weights .* exp(-alpha_min * yTrain .* h_min)'; % update weights
    weights = weights ./ sum(weights); % normalize
    
    results(t,:) = [feat_min, thresh_min, pol_min, alpha_min]; % update result matrix with current min_values
end

%% Evaluate your strong classifier here
%  Evaluate on both the training data and test data, but only the test
%  accuracy can be used as a performance metric since the training accuracy
%  is biased.

train = zeros(nbrWeakClassifiers,length(yTrain));
trainAccuracy = zeros(1, nbrWeakClassifiers);
for f = 1:nbrWeakClassifiers
    train(f,:) = results(f,4) * WeakClassifier(results(f,2), results(f,3), xTrain(results(f,1),:));
    trainPredictions = sign(sum(train(1:f,:),1));
    cm = confusionmat(yTrain,trainPredictions);
    trainAccuracy(f) = (cm(1,1)+cm(2,2))/length(yTrain);
end

test = zeros(nbrWeakClassifiers,length(yTest));
testAccuracy = zeros(1, nbrWeakClassifiers);
for f = 1:nbrWeakClassifiers
    test(f,:) = results(f,4) * WeakClassifier(results(f,2), results(f,3), xTest(results(f,1),:));
    testPredictions = sign(sum(test(1:f,:),1));
    cm = confusionmat(yTest,testPredictions);
    testAccuracy(f) = (cm(1,1)+cm(2,2))/length(yTest);
end


%% Plot the error of the strong classifier as a function of the number of weak classifiers.
%  Note: you can find this error without re-training with a different
%  number of weak classifiers.

minAccuracy = 0.93;
optNumWeakClassfiers = find(testAccuracy >= minAccuracy, 1);
optTestAccuracy = testAccuracy(1:optNumWeakClassfiers);

figure(4)
plot(1:optNumWeakClassfiers, optTestAccuracy*100)
title("Strong classifier error on test data")
xlabel("no. weak classifier")
ylabel("accuracy (%)")

%% Plot some of the misclassified faces and non-faces
%  Use the subplot command to make nice figures with multiple images.

ind = find(yTest ~= testPredictions);

figure(5);
colormap gray;
for i = 1:9
    subplot(3,3,i), imagesc(testImages(:,:,ind(i))); % misclassified faces
    axis image;
    axis off;
end

figure(6);
colormap gray;
for i = 1:9
    subplot(3,3,i), imagesc(testImages(:,:,ind(end-i))); % misclassified non-faces
    axis image;
    axis off;
end


%% Plot your choosen Haar-features
%  Use the subplot command to make nice figures with multiple images.

figure(7);
colormap gray;
i = 1;
while i <= optNumWeakClassfiers
    subplot(5,5,i), imagesc(haarFeatureMasks(:,:,results(i, 1)));
    axis image;
    axis off;
    i = i+1;
end

%% Q1
% Plot how the classification accuracy on training data and test data depend on the number of weak classifiers (in the same plot). 
% Be sure to include the number of training data (non-faces + faces), 
% test-data (non-faces + faces), and the number of Haar-Features.

figure(8)
plot(1:nbrWeakClassifiers, trainAccuracy*100)
hold on
plot(1:nbrWeakClassifiers, testAccuracy*100)
title("Classification accuracy on training data and test data")
xlabel("no. weak classifier")
ylabel("accuracy (%)")
legend('train','test')
dim = [0.6 0.15 0.1 0.1];
str = {['Number of training data = ',num2str(nbrTrainImages)],['Number of test data = ',num2str(nbrTestImages)],['Haar-features = ',num2str(nbrHaarFeatures)]};
annotation('textbox',dim,'String',str,'FitBoxToText','on');
hold off
