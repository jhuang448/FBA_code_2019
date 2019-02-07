id = '53414'; % /52993/53414
load(['/Users/caspia/Desktop/Github/FBA_code_2019/src/prediction_models/experiments/pitched_instrument_regression/data/' id '_std_note_mac .mat'])
note_mac = note;
load(['/Users/caspia/Desktop/Github/FBA_code_2019/src/prediction_models/experiments/pitched_instrument_regression/data/' id '_std_note_win.mat'])
note_win = note;
clear note;

note_mac_vec = buildPlotForNote(note_mac);
note_win_vec = buildPlotForNote(note_win);

plot(note_mac_vec);
hold on;
plot(note_win_vec, 'r');
legend('mac', 'win');