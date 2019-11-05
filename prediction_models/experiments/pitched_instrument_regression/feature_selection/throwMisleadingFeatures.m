% throw useless/misleading features
clear all;

I_tech = [];
for i = 1 % ignore tone quality
    load(string(i) + 'forward_fullset0327_tech');
    [B, I] = sort(NewList);
    I_tech = [I_tech I];
end
first50_tech = sum(I_tech<=10, 2);
sum_tech = sum(I_tech, 2);
%figure(1);
%plot(sum_tech, '*');
%hold on;
%plot([1,135], [180,180], '-');
%hold off;

I_sr = [];
for i = 1
    load(string(i) + 'forward_fullset0327_sr');
    [B, I] = sort(NewList);
    I_sr = [I_sr I];
end
first50_sr = sum(I_sr<=10, 2);
sum_sr = sum(I_sr, 2);
%figure(2);
%plot(sum_sr, '*');
%hold on;
%plot([1,135], [180,180], '-');
%hold off;

imp_sr = (first50_sr>0) & (first50_tech==0);
imp_tech = (first50_sr==0) & (first50_tech>0);

imp_both = (first50_sr>0) & (first50_tech>0);
