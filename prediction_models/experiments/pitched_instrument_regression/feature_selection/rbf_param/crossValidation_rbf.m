%% Cross Validation
% CL@GTCMT, 2015
% [Rsq, S, p, r] = crossValidation(labels, features, n_fold)
% objective: Cross validate a regression model on a training set.
%
% labels: Mx1 vector of data labels.
% features: Mx1 vector of data features.
% n_fold: int, number of folds.
% Rsq: R squared value.
% S: standard error of estimate.
% p: p value.
% r: correlation coefficient between truth & prediction.

function [Rsq, S, p, r, predictions] = crossValidation_rbf(labels, features, n_fold, c, g)

% Preallocate memory.
num_data = size(labels, 1);
predictions = zeros(num_data, 1);

% Proportional distributions of classes among folds.
folds = cvpartition(labels, 'KFold', n_fold);

% Evaluate one fold at a time.
%data_start_idx = 1;
for fold = 1:n_fold
  % Grab the test data.
  test_indices = folds.test(fold);
  test_labels = labels(test_indices, :);
  test_features = features(test_indices, :);
  data_indices = test_indices == 1;
  % Get training data.
  train_indices = folds.training(fold);
  train_labels = labels(train_indices, :);
  train_features = features(train_indices, :);
  
  % Zero-cross whitening.
%   [train_features, test_features] = whiten(train_features, test_features);
  [train_features, test_features] = NormalizeFeatures(train_features, test_features);
  
  % Train the classifier and get predictions for the current fold.
  svm = svmtrain(train_labels, train_features, char('-s 4 -t 2 -g ' + string(g) + ' -c ' + string(c) + ' -q'));
  cur_predictions = svmpredict(test_labels, test_features, svm, '-q');
  
  % Store current predictions and their corresponding labels.
  predictions(data_indices) = cur_predictions;
end

[Rsq, S, p, r] = myRegEvaluation(labels, predictions);

end