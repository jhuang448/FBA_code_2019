function [origmidi, dtw_cost, newpath] = alignScore_alignment( midi_path, f0_wav, wav, fs_w, wSize, hop )
%ALIGNSCORE: Uses dynamic time warping to align the original score of
%the current exercise with the picth contour of the student performance
%   INPUT:
%       midi_path:  path to the ground truth MIDI score
%       f0_wav:     pitch contour of the student performance
%       wav:        student performance, for onset detection
%       fs_w:       sample rate of student performance
%       wSize:      window size used in pitch estimation
%       hop:        hop size used in pitch estimation
%   OUTPUT:
%       midi_mat_aligned:   matrix that contains the score notes aligned 
%                           with the student performance
%       notes_altered:      notes in the score that were split to account
%                           for silences
%       dtw_cost:           alignment cost
%       path:               path of alignment



midi_mat = readmidi(midi_path);
orig_mat = midi_mat;

%make first onset 0, and propagate the change in onset times
%in order to make the score start from time 0
first_onset = midi_mat(1, 6);
midi_mat(:,6) = midi_mat(:,6) - first_onset;
midi_mat(1,6) = 1e-6; %0s in MIDI are handled weirdly


%normalize midi time to multiples of shortest note
%Rounding after multiplying by 2 to take into account dotted notes as well
shortest_note = min(midi_mat(:,2));
midi_mat(:,2) = midi_mat(:,2)./shortest_note;
midi_mat(:,2) = round(midi_mat(:,2)*2)/2;

%compensate for the pitch offset
%process in cents rather than hertz
wav_pitch_contour_in_midi = 69+12*log2(f0_wav/440);
wav_pitch_contour_in_midi(wav_pitch_contour_in_midi == -Inf) = 0;

%remove zeros from pitch contour
lead_trail_z = find(wav_pitch_contour_in_midi ~= 0);
wav_pitch_contour_in_midi = wav_pitch_contour_in_midi(lead_trail_z(1):lead_trail_z(end));

zeros_other = find(wav_pitch_contour_in_midi == 0);
wav_pitch_contour_in_midi(zeros_other) = [];

% perform alignment
% [~, ix, iy] = dtw(midi_mat(:,4), wav_pitch_contour_in_midi);
D = wrappedDist(midi_mat(:,4), wav_pitch_contour_in_midi, 12);
[path, C] = ToolSimpleDtw(D);
dtw_cost = C(end,end);
ix = path(:,1)';
iy = path(:,2)';

dx = diff(ix);
pos = find(dx);
true_pos = iy(pos);
time_pos = true_pos*hop/fs_w;
midi_mat_aligned = midi_mat;
midi_mat_aligned(2:end,6) = time_pos;

nvt = mySpectralFlux(wav, wSize, hop);
%remove zero frames from novelty function as well
nvt = nvt(lead_trail_z(1):min(lead_trail_z(end), end));
nvt(zeros_other) = [];
onsets = myOnsetDetection(nvt, fs_w, wSize, hop);
midi_mat_aligned = updateMidiOnsets(midi_mat_aligned, midi_mat, onsets, 50);

%Modify durations: Note onset difference for all notes but the last
%for last note, use length of pitch contour to match the end points.
midi_mat_aligned(1:end-1,7) = diff(midi_mat_aligned(:,6));
midi_mat_aligned(end, 7) = numel(wav_pitch_contour_in_midi)*hop/fs_w - midi_mat_aligned(end, 6);

%Add back starting silence to midi
midi_mat_aligned(:,6) = midi_mat_aligned(:,6) + lead_trail_z(1)*hop/fs_w;

origmidi = [];

map = zeros(size(f0_wav));
frame_note_num = zeros(size(wav_pitch_contour_in_midi));
note_frame_num = zeros(size(orig_mat, 1), 2);
%{
j = 1;
for i = 1:size(path, 1)
    if j == path(i, 2)
        frame_note_num(j) = path(i, 1);
        j = j + 1;
    end
end
map(lead_trail_z) = ...
    (orig_mat(frame_note_num, 6) + orig_mat(frame_note_num, 7)) * 100;

% linspace
st = 1; ed = 1;
while ed < size(map, 2)
    st = ed;
    v = map(st);
    ed = st + 1;
    while(ed < size(map, 2) && map(ed) == map(st))
        ed = ed + 1;
    end
    lin = linspace(map(st), map(ed), ed-st+1);
    map(st:ed-1) = lin(1:end-1);
end
%}
st = 1; ed = 0;
while ed < size(path, 1)-1
    st = ed + 1;
    ed = st + 1;
    note_num = path(st, 1);
    note_frame_num(note_num, 1) = path(st, 2);
    if ed == 2906
        5;
    end
    while(ed <= size(path, 1) && path(ed, 1) == note_num)
        ed = ed + 1;
    end
    ed = ed - 1;
    note_frame_num(note_num, 2) = path(ed, 2);
end

if ed == size(path, 1)-1
    st = ed + 1;
    note_num = path(st, 1);
    note_frame_num(note_num, 1) = path(st, 2);
    note_frame_num(note_num, 2) = path(st, 2);
end

map(lead_trail_z(note_frame_num(:, 2))) = ...
    (orig_mat(:, 6) + orig_mat(:, 7)) * 100;

newpath = map;
map_nonzero = [1, find(map ~= 0)];
newpath(map_nonzero(end):end) = map(map_nonzero(end));

for i = 1:size(map_nonzero, 2)-1
    st = map_nonzero(i);
    ed = map_nonzero(i+1);
    
    lin = linspace(map(st), map(ed), ed-st+1);
    newpath(st:ed-1) = lin(1:end-1);
end

newpath;
% find non-zero points

end

function midi_mat = addSilence(midi_mat, previous_note, hop, fs_w)
    for i = previous_note + 1:size(midi_mat,1)
        midi_mat(i,6) = midi_mat(i,6) + hop/fs_w; %add one frame of silence
    end
end

function [midi_mat, split_note] = splitNote(midi_mat, previous_note, pos, hop, fs_w)
    split_note = [];
    onset_time = midi_mat(previous_note,6);
    duration = midi_mat(previous_note, 7);
    
    onset_note_1 = onset_time;
    duration_note_1 = (pos)*hop/fs_w - onset_time;

    onset_note_2 = (pos)*hop/fs_w;
    duration_note_2 = onset_time+duration - (pos)*hop/fs_w;

    note_1 = [onset_note_1, duration_note_1, midi_mat(previous_note, 3:5), onset_note_1, duration_note_1];
    note_2 = [onset_note_2, duration_note_2, midi_mat(previous_note, 3:5), onset_note_2, duration_note_2]; 
    % check if silence is at note off or during note to split
    if(((pos-1)*hop/fs_w - onset_time >= duration) || (duration_note_2 <= 1e-6))
        midi_mat = addSilence(midi_mat, previous_note, hop, fs_w);
    else
        if(duration_note_1 <= 1e-6) %note was not played yet
%             midi_mat(previous_note,7) = duration_note_1;
            midi_mat = [midi_mat(1:previous_note-1,:); note_2; midi_mat(previous_note+1:end,:)];
            midi_mat = addSilence(midi_mat, previous_note - 1, hop, fs_w);
        else %split note
            split_note = previous_note;
            midi_mat = [midi_mat(1:previous_note-1,:); note_1; note_2; midi_mat(previous_note+1:end,:)];
            midi_mat = addSilence(midi_mat, previous_note, hop, fs_w);
        end
    end
end