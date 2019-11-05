function aligned_path = extractAlignment(audio, f0, Fs, wSize, hop, score_path)

%slashtype = getSlashType();

timeStep = hop/Fs;

% get the score to pass to the feature extraction function
%root_path = deriveRootPath();
%BAND_OPTION = 'middleschool'; % NEED TO ADD THIS AS FUNCTION PARAMETER LATER
if isempty(score_path)
    error('Invalid score path');
end
[scoreMid, mstr] = readmidi(score_path);
[rwSc, clSc] = size(scoreMid);

[tf, flag] = findTuningFrequency(f0);
pitch_in_midi = 69+12*log2(f0/440);
pitch_in_midi(pitch_in_midi == -Inf) = 0;
pitch_in_midi2 = pitch_in_midi;

pitch_in_midi(pitch_in_midi~=0) = pitch_in_midi(pitch_in_midi~=0) - (tf/100);
tfCompnstdF0 = pitch_in_midi;
tfCompnstdF0(tfCompnstdF0~=0) = (2.^((pitch_in_midi(tfCompnstdF0~=0)-69)/12))*440;

if flag == 1
    pitch_in_midi2(pitch_in_midi2~=0) = pitch_in_midi2(pitch_in_midi2~=0) + (tf/100);
    tfCompnstdF02 = pitch_in_midi2;
    tfCompnstdF02(tfCompnstdF02~=0) = (2.^((pitch_in_midi2(tfCompnstdF02~=0)-69)/12))*440;
    [origmidi1, dtw_cost1, path1] = alignScore_alignment(score_path, tfCompnstdF0, audio, Fs, wSize, hop);
    [origmidi2, dtw_cost2, path2] = alignScore_alignment(score_path, tfCompnstdF02, audio, Fs, wSize, hop);
    if dtw_cost2 > dtw_cost1
       origmidi = origmidi1;
       dtw_cost = dtw_cost1;
       path = path1;
    else
       origmidi = origmidi2;
       dtw_cost = dtw_cost2;
       path = path2;
    end
else
    [origmidi, dtw_cost, path] = alignScore_alignment(score_path, tfCompnstdF0, audio, Fs, wSize, hop);
end

% TODO: conver algndmidi to a time series which have the same length as
% pitch contour

%{
aligned_midi = zeros(size(f0));
unit = hop/Fs;
for i = 1:size(algndmidi, 1)
    st = round(algndmidi(i, 6)/unit);
    ed = round((algndmidi(i, 6) + algndmidi(i, 7))/unit) - 1;
    aligned_midi(st:ed) = algndmidi(i, 4);
end
%}
aligned_path = path;
end