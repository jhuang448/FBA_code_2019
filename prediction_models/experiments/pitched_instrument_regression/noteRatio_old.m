function retV = noteRatio_old(path, onsetMidi)
% compute 'note ratio' features
% the weighted mean and weighted std of the ratio vectors
% iftempo not used

l = size(path, 1);
frameEnd = path(end, 2);

path_onset = find(path(2:l, 1)-path(1:l-1, 1)) + 1;
path_onset = [1; path_onset];

onset_audio = path(path_onset, :);

path_njump = onset_audio(end,2);
i = size(onset_audio, 1)-1;
cmp = onset_audio(end, 1);
while i > 0
    if onset_audio(i, 1) < cmp
        cmp = onset_audio(i, 1);
        path_njump = [onset_audio(i, 2) path_njump];
    end
    i = i - 1;
end

path_njump = [path_njump, frameEnd+1];

% noteAudio: length in frame of every note in the audio
noteAudio = diff(path_njump);
% noteMidi: length in beat of every note in midi
noteMidi = diff(onsetMidi);

noteAudio = noteAudio(2:end-1);
noteMidi = noteMidi(2:end-1);

idx = (noteAudio > 3) & (noteMidi' > 0);
noteAudio = noteAudio(idx);
noteMidi = noteMidi(idx);

w = noteMidi/sum(noteMidi);
ratio1 = noteAudio./noteMidi';

w_mean1 = mean(ratio1.*w');
w_std1 = std(ratio1, w');
w_mean2 = mean(ratio1);
w_std2 = std(ratio1);

retV = [w_mean1 w_std1 w_mean2 w_std2];
