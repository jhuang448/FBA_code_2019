%% scriptSaveAlignment
% script to compute and save training data in different configurations

warning off;

% specify configuration
segment_option = 2;
band_options = {'middle', 'symphonic'};
instrument_options = {'Bb Clarinet', 'Flute', 'Alto Saxophone'};
year_options = {'2013','2014','2015'};

pitch_option = 'pyin'; % options are 'pyin' and 'acf'
quick = 0;
forcerun = 1;

data_folder = '/Users/caspia/Desktop/Github/FBA-Fall19/data/midi/aligned_'

%% Compute and Save Features
for b = 1:length(band_options)
    band = band_options{b};
    disp(band);
    alignment_band = cell(1, 3);
    ids_band = cell(1, 3);
    
    % check if file exists
    if quick == 1
        quick_string = 'quick';
    else    
        quick_string = '';
    end
    
    filestring = [data_folder, band, quick_string, '.mat'];
    for y = 1:length(year_options)
        year = year_options{y};
        disp(year);
        alignment_year = [];
        ids_year = [];
        for i = 1:length(instrument_options)
            instrument = instrument_options{i};
            disp(instrument);
            
            if exist(filestring, 'file') ~= 2 | forcerun == 1
                [Alignment, student_ids] = createAlignment(...
                    band, instrument, segment_option, year,...
                    pitch_option, quick);
                alignment_year = [alignment_year Alignment];
                ids_year = [ids_year; student_ids];
            end
        end
        alignment_band{y} = alignment_year;
        ids_band{y} = ids_year;
    end
    save(filestring, 'alignment_band', 'ids_band');
    %warnwave
    WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
    Audio = audioplayer(WarnWave, 22050);
    play(Audio);
end

