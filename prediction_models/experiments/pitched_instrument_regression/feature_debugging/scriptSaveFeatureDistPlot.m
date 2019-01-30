%% scriptSaveFeatureDistPlot
%% script to plot the distribution plot for each feature and save the plot

% specify configuration
segment_option = 5;
band = 'middle';
instrument = 'Alto Saxophone';
year_options = {'2013', '2014', '2015'};
feature = 'std';
feature_num = 68;
pitch_option = 'pyin'; % options are 'pyin' and 'acf'
if strcmp(pitch_option, 'pyin') == 1
    data_folder = '../dataPyin/';
else
    data_folder = '../data/';
end

allFeatures = [];
allIds = [];

for y = 1:length(year_options)
    year = year_options{y};
    disp(year);
    feature_filestring = [data_folder, band, instrument, ...
        num2str(segment_option), '_', feature, '_', year, '.mat'];
    load(feature_filestring);
    allFeatures = [allFeatures; features];
    allIds = [allIds; student_ids];
end

for fid = 1:feature_num
    histogram(allFeatures(:, fid), 20);
    saveas(gcf, ["hist/hist_" + feature + "_" + string(fid) + "_.png"]);
end


