function shift_n = computeShiftN(wav_mac, wav_win, length)
% compute the shift
cost = zeros(1, 500);
for i = 1501:2000
    cost(i-1500) = sum(abs(wav_win(i+1:i+length)-wav_mac(1:length)))/length;
end
plot(cost);
[diff, shift_n] = min(cost);
shift_n = shift_n + 1500;
diff
% average difference is about e-05 per sample