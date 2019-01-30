%% scriptSaveTrainingData
% script to compute and save training data in different configurations

% specify configuration
segment_option = 5;
band_options = {'middle'};
instrument_options = {'Alto Saxophone'};
year_options = {'2013','2014','2015'};
feature_options = {'score revDTW'};
pitch_option = 'acf'; % options are 'pyin' and 'acf'
quick = 0;
if strcmp(pitch_option, 'pyin') == 1
    data_folder = 'dataPyin/';
else
    data_folder = 'data/';
end

%% Compute and Save Features
for b = 1:length(band_options)
    band = band_options{b};
    disp(band);
    for i = 1:length(instrument_options)
        instrument = instrument_options{i};
        disp(instrument);
        for y = 1:length(year_options)
           year = year_options{y};
           disp(year);
           for f = 1:length(feature_options)
                feature = feature_options{f};
                disp(feature);
                % check if file exists
                if quick == 1
                    quick_string = 'quick';
                else    
                    quick_string = '';
                end
                feature_filestring = [data_folder, band, instrument, ...
                    num2str(segment_option), '_', feature, '_', year, ...
                    quick_string, 'noteRatio.mat'];
                if exist(feature_filestring, 'file') ~= 2
                    [features, labels, student_ids] = createTrainingData(...
                        band, instrument, segment_option, year,...
                        pitch_option, feature, quick);
                    
                    % tone quality, 2015 has a different score range with
                    % other years
                    if strcmp(year, '2015') == 1
                        labels(:, 4) = labels(:, 4)/2;
                    end
                    
                    save(feature_filestring, 'features', 'labels', 'student_ids');
                end
                
                %warnwave
                WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
                Audio = audioplayer(WarnWave, 22050);
                play(Audio);
           
           end
        end
    end
end

