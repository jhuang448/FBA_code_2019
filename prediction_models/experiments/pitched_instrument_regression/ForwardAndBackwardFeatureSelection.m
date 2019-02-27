clear all;
close all;
clc;
warning off;

% AV@GTCMT
% Objective: To perform feature selection using forward and backward
% feature selection procedure. Maximum accuracy at each feature combination
% is plotted in the end.

DATA_PATH = 'experiments/pitched_instrument_regression/feature_selection/';
write_file_name = 'featuresFullset135';

% Check for existence of path for reading stored features and labels.
root_path = deriveRootPath();
full_data_path = [root_path DATA_PATH];

load([full_data_path write_file_name]);
%{
% concatenate features in all three years
load([full_data_path write_file_name '3']);
features_a = features;
labels_a = labels;
load([full_data_path write_file_name '4']);
features_a = [features_a; features];
labels_a = [labels_a; labels];
load([full_data_path write_file_name '5']);
features_a = [features_a; features];
labels_a = [labels_a; labels];

features = features_a;
labels = labels_a;
%}

% select the size of the data to perform leave one file out validation
NUM_FOLDS = 5; % size(features_a, 1);

% % To perform the same experiment with bag of features plus the designed 
% % features uncomment the code below
% featuresCombined = features;
% 
% % Load Bag Of Features
% DATA_PATH = 'experiments\pitched_instrument_regression\BagOfFeatures_altosax\';
% write_file_name = 'middleAlto Saxophone4';
% 
% load([full_data_path write_file_name]);
% featuresCombined = [featuresCombined features];
% % features=featuresCombined;

% Choose the label on which assessment is needed.
for l_id = 2:4 % 3: rhythmic accuracy
    
    labels_i = labels(:,l_id); %labels(:,2),labels(:,3)

    % Evaluate model using cross validation.
    [Rsq_allFeat, S_allFeat, p_allFeat, r_allFeat] = crossValidation(labels_i, features, NUM_FOLDS);
    display('With all the features');
    display(r_allFeat);
    display(p_allFeat);

    [~,numFeat]=size(features);


    % greedy feature combination: forward direction
    Rsq = zeros(numFeat,1);
    S = zeros(numFeat,1);
    p = zeros(numFeat,1);
    r = zeros(numFeat,1);
    for i=1:numFeat
        [Rsq(i), S(i), p(i), r(i)] = crossValidation(labels_i, features(:,i), NUM_FOLDS);
    end

    % first select feature with maximum correlation coefficient
    [val,loc]=max(r);
    display('Single feature ranking result');
    display(val);
    display('P value');
    display(p(loc));
    display('corresponding to feature number');
    display(loc);

    Regr(1,1)=r_allFeat;
    Regr(2,1)=p_allFeat;
    Regr(1,2)=val;
    Regr(2,2)=p(loc);

    featureList=1:numFeat;
    NewList=[];
    NewList=[NewList;featureList(loc)];
    AccuList=[val];
    Accu_past=val;
    p_max=p(loc);

    Rsq = zeros(numFeat,1);
    S = zeros(numFeat,1);
    p = zeros(numFeat,1);
    r = zeros(numFeat,1);

    featureList(loc)=[];
    Accu_present=Accu_past;

    while isempty(featureList)~=1
        display(size(featureList,2));
        Accu_past=Accu_present;
        AccuArr=zeros(length(featureList),1);

        for iter=1:length(featureList)
            [Rsq(iter), S(iter), p(iter), AccuArr(iter)]=crossValidation(labels_i, [features(:,featureList(iter)) features(:,NewList')],NUM_FOLDS);

        end

        Accu_present=max(AccuArr);
        [Accu_present,loc]=max(AccuArr);
        AccuList=[AccuList,Accu_present];
        NewList=[NewList;featureList(loc)];
        featureList(loc)=[];
        p_max=p(loc);

    end

    %forward selection plot
    figure(l_id);
    plot(AccuList);

    display('Best feature combination with')
    display(NewList)
    display('and the corresponding accuracy')
    display(AccuList(end));

    Regr(1,3)=AccuList(end);
    Regr(2,3)=p_max;

    save('feature_selection/' + string(l_id) + 'forward_fullset0227','NewList', 'AccuList');

end
%{
% greedy feature combination: backward direction
[val]=r_allFeat;

featureListBack=1:numFeat;
AccuListBack=[val];
Accu_past=val;
BackFeatDrop=[];
Accu_present=Accu_past;

while isempty(featureListBack)~=1
    display(size(featureListBack,2));
    Accu_past=Accu_present;
    AccuArrBack=zeros(length(featureListBack),1);
    
    for iter=1:length(featureListBack)
        TempFeatList=featureListBack;
        TempFeatList(:,iter)=[];
        [Rsq(iter), S(iter), p(iter), AccuArrBack(iter)]=crossValidation(labels(:, l_id),features(:,TempFeatList),NUM_FOLDS);
    end
    
    Accu_present=max(AccuArrBack);
    [Accu_present,loc]=max(AccuArrBack);
    AccuListBack=[AccuListBack,Accu_present];
    BackFeatDrop=[BackFeatDrop;featureListBack(loc)];
    featureListBack(loc)=[];
    
end

%backward selection plot
figure; plot(AccuListBack);

display('Best feature combination with')
display(featureListBack)
display('and the corresponding accuracy')
display(AccuListBack(end));
display('with p value of');
display(p(loc));

Regr(1,4)=AccuListBack(end);
Regr(2,4)=p(loc);

save('feature_selection/' + string(l_id) + 'backward_fullset0227','NewList', 'AccuList');
%}

%warnwave
WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);
play(Audio);
