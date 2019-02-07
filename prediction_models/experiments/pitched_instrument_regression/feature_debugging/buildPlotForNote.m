function note_vec = buildPlotForNote(note)

l = length(note);
note_vec = zeros(1, note(l).stop);

for i=1:l
    note_vec(note(i).start:note(i).stop) = note(i).mean_pitch_hz;
end
