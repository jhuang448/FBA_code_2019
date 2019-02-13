function note_ratio = noteratio1(path, midi_mat)

notelength_frame = find(path(2:end, 1)-path(1:end-1, 1));
note_id = path([1; notelength_frame+1], 1);
notelength_frame = [notelength_frame; size(path,1)];
notelength_frame = [path(notelength_frame(1),2); path(notelength_frame(2:end),2)-path(notelength_frame(1:end-1),2)];

shortest_note = min(midi_mat(:,2));
notelength_midi = midi_mat(:,2)./shortest_note;
notelength_midi = round(notelength_midi*2)/2;

note_ratio = notelength_frame./notelength_midi(note_id);
note_ratio = note_ratio(note_ratio>0);