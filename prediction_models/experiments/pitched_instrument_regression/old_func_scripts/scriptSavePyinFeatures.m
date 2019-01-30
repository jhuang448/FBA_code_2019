%% scriptSavePyinFeatures
% script to compute and save pYin score, non-score features
% for all bands and all instruments

% specify configuration
band = 'middle';
inst_strings = {'Alto Saxophone','Bb Clarinet', 'Flute'};
segment = 4;
pitch_contour_type = 'pyin'; % options are 'pyin' and 'acf'
if strcmp(pitch_contour_type, 'pyin') == 1
    data_folder = 'dataPyin/';
    function_suffix = 'Pyin';
else
    data_folder = 'data/';
    function_suffix = '';
end

%default parameter values (Do NOT change this)
num_nonscore = 24;
num_score = 22;
non_score_filestring = '_NonScore_';
score_filestring = '_Score_';
combined_filestring = '_Combined_';
std_filestring = '_baseline_';

%% Compute and Save Features
year_strings = {'2013', '2014', '2015'};
for j=1:length(inst_strings)
    inst = inst_strings{j}
    for i=1:length(year_strings)
        year_string = year_strings{i};
        % compute feature if file doesn't exist already
        std_feature_file = [data_folder, band, inst, num2str(segment), std_filestring, year_string, '.mat' ];
        if exist(std_feature_file, 'file') ~= 2
            getStdFeaturesForSegment(band, inst, segment, year_string);
        end
        non_score_feature_file = [data_folder, band, inst, num2str(segment), non_score_filestring, year_string, '.mat'];
        if exist(non_score_feature_file, 'file') ~= 2
            ns_func_handle = str2func(['getFeatureForSegment', function_suffix]);
            ns_func_handle(band, inst, segment, year_string, num_nonscore);
        end
        if and(strcmp(inst, 'Alto Saxophone') == 1, segment==2)
            score_feature_file = [data_folder, band, inst, num2str(segment), score_filestring, year_string, '.mat'];
            if exist(score_feature_file, 'file') ~= 2
                s_func_handle = str2func(['getScoredFeatureForSegment', function_suffix]);
                s_func_handle(band, inst, segment, year_string, num_score);
            end
            % combine non-score and score based features
            combined_feature_file = [data_folder, band, inst, num2str(segment), combined_filestring, year_string, '.mat'];
            load(non_score_feature_file);
            features1 = features;
            load(score_feature_file);
            features = [features1, features];
            save(combined_feature_file, 'features', 'labels', 'student_ids');
        end
    end
end
