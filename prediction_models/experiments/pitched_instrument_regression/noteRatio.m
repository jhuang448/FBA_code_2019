function retV = noteRatio(path, onsetMidi)
% compute 'note ratio' features
% the weighted mean and weighted std of the ratio vectors

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

% remove short note
%idx = (noteAudio > 3) & (noteMidi' > 0);
%noteAudio = noteAudio(idx);
%noteMidi = noteMidi(idx);

% v_note: assume time signature is 4/4 or 2/4
[beat, frame] = convertToBeat(noteMidi', noteAudio);
[v_qnote, infn] = tempoPerBeats(frame, 1);
v_hnote = tempoPerBeats(frame, 2);
v_wnote = tempoPerBeats(frame, 4);

% plot the vectors; the first two make more sense (rhythmic accuracy)
%{
subplot(3,1,1);
plot(v_qnote);
ylim([0 0.02]);
subplot(3,1,2);
plot(v_hnote);
ylim([0 0.02]);
subplot(3,1,3);
plot(v_wnote);
ylim([0 0.02]);
close(gcf);
%}

assert(sum(noteMidi<0) == 0);

retV = [mean(v_qnote) std(v_qnote) mean(v_hnote) std(v_hnote) mean(v_wnote) std(v_wnote) infn];
end

function [b, f] = convertToBeat(onset_m, onset_a)
l = length(onset_m);
b= [];
f = [];
i = 1;
sum_t = 0;
sum_f = 0;
while (i <= l)
    if (sum_t + onset_m(i) < 1)
        sum_t = sum_t + onset_m(i);
        sum_f = sum_f + onset_a(i);
    elseif (sum_t + onset_m(i) == 1)
        b = [b; 1];
        f = [f; sum_f + onset_a(i)];
        sum_t = 0;
        sum_f = 0;
    else % sum_t + onset_m(i) > 1
        b = [b; 1];
        f = [f; sum_f + onset_a(i) * (1-sum_t)/onset_m(i)];
        sum_t = onset_m(i)-1+sum_t;
        sum_f = onset_a(i) * (1-(1-sum_t)/onset_m(i));
    end
    
    while(sum_t>1)
        b = [b; 1];
        f = [f; sum_f * (1/sum_t)];
        sum_f = sum_f * (1-1/sum_t);
        sum_t = sum_t - 1;
    end
    i = i + 1;
end

if sum_t > 0
    b = [b; 1];
    f = [f; sum_f * (1/sum_t)];
end

end

function [v_note, infn] = tempoPerBeats(v, beatNum)
l = floor(length(v)/beatNum);
v_note = zeros(1, l);
for i = 1:l
    v_note(i) = beatNum/sum(v((i-1)*beatNum+1:i*beatNum));
end

infn = sum(v_note==Inf);
v_note = v_note(v_note < Inf);
end