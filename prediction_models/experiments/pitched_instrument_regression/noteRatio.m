function retV = noteRatio(path, onsetMidi)
% compute 'note ratio' features
% the weighted mean and weighted std of the ratio vectors

l = size(path, 1);
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

noteAudio = diff(path_njump);
noteMidi = diff(onsetMidi);
idx = (noteAudio > 3) & (noteMidi' > 0);
noteAudio = noteAudio(idx);
noteMidi = noteMidi(idx);
w = noteMidi/sum(noteMidi);
ratio1 = noteAudio./noteMidi';
ratio2 = noteMidi'./noteAudio;
w_mean1 = mean(ratio1.*w');
w_std1 = sqrt(var(ratio1, w'));
w_mean2 = mean(ratio2.*w');
w_std2 = sqrt(var(ratio2, w'));
retV = [w_mean1 w_std1 w_mean2 w_std2];

