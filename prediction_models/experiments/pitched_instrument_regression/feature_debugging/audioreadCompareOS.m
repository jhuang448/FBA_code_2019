% compare features extracted on different OS
% 2015 middle alto-saxophone std

load('data/middleAlto Saxophone5_std_2015win', 'features');
features_win = features;
load('data/middleAlto Saxophone5_std_2015mac', 'features');
features_mac = features;
clear features;

diff = abs(features_win-features_mac)./abs(features_win);
t_f = sum(diff>0.05);
t_d = sum(diff>0.05, 2);

subplot(2,1,1);
plot(t_f, '*');
xlabel('features');
subplot(2,1,2);
plot(t_d, '*r');
xlabel('student');

% remove studeng 40 & 52:
diff_s = diff([1:39 41:51 53:end], :);
t_f = sum(diff_s>0.05);
t_d = sum(diff_s>0.05, 2);
subplot(2,1,1);
plot(t_f, '*');
xlabel('features');
subplot(2,1,2);
plot(t_d, '*r');
xlabel('student');

% remove feature 8 & 42
diff_f = diff(:, [1:7 9:41 43:end]);
t_f = sum(diff_f>0.05);
t_d = sum(diff_f>0.05, 2);
subplot(2,1,1);
plot(t_f, '*');
xlabel('features');
subplot(2,1,2);
plot(t_d, '*r');
xlabel('student');

% feature list:
%{
1:4
mean of 'within-note mean' of 
'SpectralCentroid',
'SpectralRolloff',
'TimeZeroCrossingRate',
5:8
mean of 'within-note std' of
'SpectralCentroid',
'SpectralRolloff',
'TimeZeroCrossingRate',                     <-8
9:21
mean of 'within-note mean' of 
MFCCs
22:34
mean of 'within-note std' of
MFCCs

35:38
std of 'within-note mean' of 
'SpectralCentroid',
'SpectralRolloff',
'TimeZeroCrossingRate',
39:42
std of 'within-note std' of
'SpectralCentroid',
'SpectralRolloff',                          <-41
'TimeZeroCrossingRate',                     <-42
43:55
std of 'within-note mean' of 
MFCCs
56:68
std of 'within-note std' of
MFCCs
%}