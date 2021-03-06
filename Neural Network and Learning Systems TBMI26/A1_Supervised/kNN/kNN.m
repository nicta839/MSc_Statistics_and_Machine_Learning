function [ LPred ] = kNN(X, k, XTrain, LTrain)
% KNN Your implementation of the kNN algorithm
%    Inputs:
%              X      - Samples to be classified (matrix)
%              k      - Number of neighbors (scalar)
%              XTrain - Training samples (matrix)
%              LTrain - Correct labels of each sample (vector)
%
%    Output:
%              LPred  - Predicted labels for each sample (vector)

classes = unique(LTrain);

% Add your own code here
LPred  = zeros(size(X,1),1);

% Calculate distance between all the points
% Generate a matrix of these distances
D = pdist2(X, XTrain); %each row is the distance between point X(i,:) and XTrain(j,:)

% Sort distances
[~, idx] = sort(D, 2);


for i = 1:size(idx, 1)
   temp_idx = idx(i,:);
   klabels = LTrain(temp_idx);
   kn = klabels(1:k);
   count = tabulate(kn);
   maj_vote = length(find(count(:, 2) == max(count(:, 2))));
   if maj_vote > 1
       LPred(i) = kn(1);
   else
       [~, label_idx] = max(count(:, 2));
       LPred(i) = classes(label_idx);
   end
end

end


