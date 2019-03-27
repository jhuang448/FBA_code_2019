function [amp_hist_feature, ampenv_peaks] = computeDynamicFeatures(time_pos, audio, fs_w)
amp_hist_feature = zeros(1, size(time_pos, 1));
ampenv_peaks = zeros(1, size(time_pos, 1));
ShortNotes = [];
for i = 1:size(time_pos,1)
    if(time_pos(i,2) < 0.1)
        ShortNotes = [ShortNotes i];
        continue;
    end
    st = floor(time_pos(i,1)*fs_w);
    ed = floor((time_pos(i,1)+time_pos(i,2))*fs_w);
    if ed > length(audio)
        ed = length(audio);
    end    
    audio_note = audio(st:ed);
    amp_hist_feature(i) = ampHist(audio_note,fs_w);
    ampenv_peaks(i) = ampEnvPeaks(audio_note, fs_w);
end
amp_hist_feature(ShortNotes) = [];
ampenv_peaks(ShortNotes) = [];
