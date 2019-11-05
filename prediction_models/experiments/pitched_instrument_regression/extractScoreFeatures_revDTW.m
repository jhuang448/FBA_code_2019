function [features] = extractScoreFeatures_revDTW(audio, f0, Fs, wSize, hop, score_path, NUM_FEATURES)

%slashtype = getSlashType();
features=zeros(1,NUM_FEATURES);
timeStep = hop/Fs;

% get the score to pass to the feature extraction function
%root_path = deriveRootPath();
%BAND_OPTION = 'middleschool'; % NEED TO ADD THIS AS FUNCTION PARAMETER LATER
if isempty(score_path)
    error('Invalid score path');
end
[scoreMid, nstr]= readmidi(score_path);
[rwSc, clSc] = size(scoreMid);

[tf, flag] = findTuningFrequency(f0);
pitch_in_midi = 69+12*log2(f0/440);
pitch_in_midi(pitch_in_midi == -Inf) = 0;
pitch_in_midi2 = pitch_in_midi;

pitch_in_midi(pitch_in_midi~=0) = pitch_in_midi(pitch_in_midi~=0) - (tf/100);
tfCompnstdF0 = pitch_in_midi;
tfCompnstdF0(tfCompnstdF0~=0) = (2.^((pitch_in_midi(tfCompnstdF0~=0)-69)/12))*440;

% jump: 2*1 vector, jump number & jump distance

if flag == 1
    pitch_in_midi2(pitch_in_midi2~=0) = pitch_in_midi2(pitch_in_midi2~=0) + (tf/100);
    tfCompnstdF02 = pitch_in_midi2;
    tfCompnstdF02(tfCompnstdF02~=0) = (2.^((pitch_in_midi2(tfCompnstdF02~=0)-69)/12))*440;
    [algndmid1, note_onsets1, dtw_cost1, path1, jp1] = alignScore_revDTW(score_path, tfCompnstdF0, audio, Fs, wSize, hop);
    [algndmid2, note_onsets2, dtw_cost2, path2, jp2] = alignScore_revDTW(score_path, tfCompnstdF02, audio, Fs, wSize, hop);
    if dtw_cost2 > dtw_cost1
       algndmidi = algndmid1;
       note_altrd = note_onsets1;
       dtw_cost = dtw_cost1;
       path = path1;
       jump = jp1;
    else
       algndmidi = algndmid2;
       note_altrd = note_onsets2;
       dtw_cost = dtw_cost2;
       path = path2;
       tfCompnstdF0 = tfCompnstdF02;
       jump = jp2;
    end
else
    [algndmidi, note_altrd, dtw_cost, path, jump] = alignScore_revDTW(score_path, tfCompnstdF0, audio, Fs, wSize, hop);
end

[slopedev, ~] = slopeDeviation(path);
[rwStu, clStu] = size(algndmidi);

% features over each individual note and then its derived statistical features
NoteAvgDevFromRef = zeros(1,rwStu); NoteStdDevFromRef = zeros(1,rwStu); NormCountGreaterStdDev = zeros(1,rwStu);
ShortNotes = [];
numSampShortNotes = [];

for i=1:rwStu
    strtTime = round(algndmidi(i,6)/timeStep);
    endTime = round(algndmidi(i,6)/timeStep + algndmidi(i,7)/timeStep-1);
    pitchvals=(tfCompnstdF0(strtTime:endTime));
    if (numel(pitchvals) < 3) %note played is too short i.e. around 10 ms
        ShortNotes = [ShortNotes, i];
        numSampShortNotes = [numSampShortNotes, numel(pitchvals)];
    else
        [NoteAvgDevFromRef(1,i),NoteStdDevFromRef(1,i),NormCountGreaterStdDev(1,i)]=NoteSteadinessMeasureWithRefScore(pitchvals(pitchvals~=0), algndmidi(i,4));
    end
end
% Remove Short Notes
NoteAvgDevFromRef(ShortNotes) = [];
NoteStdDevFromRef(ShortNotes) = [];
NormCountGreaterStdDev(ShortNotes) = [];
[amp_hist_feature, ampenv_peaks] = computeDynamicFeatures(algndmidi(:, [6,7]), audio, Fs);

% Group (in the paper): Pitch
features(1,1)=mean(NoteAvgDevFromRef);
features(1,2)=std(NoteAvgDevFromRef);
features(1,3)=max(NoteAvgDevFromRef);
features(1,4)=min(NoteAvgDevFromRef);
 
features(1,5)=mean(NoteStdDevFromRef);
features(1,6)=std(NoteStdDevFromRef);
features(1,7)=max(NoteStdDevFromRef);
features(1,8)=min(NoteStdDevFromRef); 

% Group: DTW cost
features(1,9)=dtw_cost(1)/length(path);
features(1,10) = dtw_cost(2)/length(path); % cost of jumped segments
features(1,11) = dtw_cost(3)/length(path); % cost of other parts

% Group: Tempo var.
features(1,12)=slopedev;
features(1,13) = jump(1); % number of jumps
features(1,14) = jump(2); % distance of jumps

% Group: NIR, NDR
features(1,15) = sum(algndmidi(:,7))/(sum(algndmidi(:,7))+sum(algndmidi(note_altrd+1,6)-(algndmidi(note_altrd,6)+algndmidi(note_altrd,7))));
features(1,16) = sum(numSampShortNotes)*timeStep / sum(algndmidi(:,7));

% Group: Tempo (local)
noteRatio_tmp = noteRatio(path(:, [1, 3]), [scoreMid(:, 1); scoreMid(end, 1) + scoreMid(end, 2)], 0);
features(1,17:18) = noteRatio_tmp(9:10);

% Group: Tempo (IOI)
[note_indices] = computeNoteOccurence(scoreMid);
vecDurFeat = DurHistScore(algndmidi, note_indices, note_altrd, Fs, timeStep);
features(1,19:24) = vecDurFeat';

% Group: Dynamics
features(1,25)=mean(amp_hist_feature);
features(1,26)=std(amp_hist_feature);
features(1,27)=max(amp_hist_feature);
features(1,28)=min(amp_hist_feature);

features(1,29)=mean(ampenv_peaks);
features(1,30)=std(ampenv_peaks);
features(1,31)=max(ampenv_peaks);
features(1,32)=min(ampenv_peaks);

end