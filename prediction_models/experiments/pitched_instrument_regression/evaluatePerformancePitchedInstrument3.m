%% Evaluate Regression for Pitched Instrument 
% evaluatePerformancePitchedInstrument2_1(read_file_name1, read_file_name2, test_file_name, flag)
% objective: Evaluate regression model for pitched instrument experiment.
%
% read_file_name: string, name of file to read training data from.
% flag: if combine other data files
% ifpYin: if the data files are saved in the pYin folder

function mtc = evaluatePerformancePitchedInstrument3(read_file_name1, read_file_name2, test_file_name, flag, ifpYin)
warning off;
NUM_FOLDS = 10;
DATA_PATH = 'experiments/pitched_instrument_regression/data/';
if ifpYin == 1
    DATA_PATH = 'experiments/pitched_instrument_regression/dataPyin/';
end

%load('feature_selection/3');
%feature_list = NewList(1:22);

%flag: whether to combine features
flag = 0;%set flag to 0: not combining features
cmbf1 = ['middleAlto Saxophone5_Score_fixedrevDTW_' read_file_name1(end-3:end)];
cmbf2 = ['middleAlto Saxophone5_Score_fixedrevDTW_' read_file_name2(end-3:end)];
cmbf3 = ['middleAlto Saxophone5_Score_fixedrevDTW_' test_file_name(end-3:end)];

% Check for existence of file with training data features and labels.
if(exist('read_file_name1', 'var') && exist('read_file_name2', 'var'))
  root_path = deriveRootPath();
  full_data_path = [root_path DATA_PATH];
  
  if(~isequal(exist(full_data_path, 'dir'), 7))
    error('Error in your file path.');
  end
else
  error('No file name specified.');
end

% Load training data.
load([full_data_path read_file_name1]);
features1 = features;
llb = size(labels, 2);
labels1 = labels(:, llb-3:llb);
%idx1 = student_idx;
if flag == 1
    load([full_data_path cmbf1]);
    
    assert(size(features1, 1) == size(features, 1));
    features1 = [features1, features];
end
load([full_data_path read_file_name2]);
features2 = features;
llb = size(labels, 2);
labels2 = labels(:, llb-3:llb);
if flag == 1
    load([full_data_path cmbf2]);

    assert(size(features2, 1) == size(features, 1));
    features2 = [features2, features];
end
%idx2 = student_idx;

load([full_data_path test_file_name]);
features3 = features;
llb = size(labels, 2);
labels3 = labels(:, llb-3:llb);
%idx3 = student_idx;
if flag == 1
    load([full_data_path cmbf3]);

    assert(size(features3, 1) == size(features, 1));
    features3 = [features3, features];
end

all_features = [features1; features2; features3];
all_labels = [labels1; labels2; labels3];

mtc = zeros(4, 11, 4);

for i = 1:4
    %for j = 23:33
        [Rsq, S, p, r] = crossValidation(all_labels(:, i), all_features(:, [1:28]), NUM_FOLDS);
        %mtc(i, j-22, :) = [Rsq, S, p, r];
        fprintf(['\nResults complete.\nR squared: ' num2str(Rsq) ...
                 '\nStandard error: ' num2str(S) '\nP value: ' num2str(p) ...
                 '\nCorrelation coefficient: ' num2str(r) '\n']);
    %end
%q_pdt = round(pdt.*10)./10;
%save(['predictions/Score_alignLength_453'], 'pdt', 'test_labels');
end