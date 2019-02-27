load('1forward_fullset0227');
acc{1} = AccuList;
flist{1} = NewList;
[~, maxIdx{1}] = max(AccuList);
figure(1);
plot(AccuList);
title('musicality');

load('2forward_fullset0227');
acc{2} = AccuList;
flist{2} = NewList;
[~, maxIdx{2}] = max(AccuList);
figure(2);
plot(AccuList);
title('note accuracy');

load('3forward_fullset0227');
acc{3} = AccuList;
flist{3} = NewList;
[~, maxIdx{3}] = max(AccuList);
figure(3);
plot(AccuList);
title('rhythmic accuracy');

load('4forward_fullset0227');
acc{4} = AccuList;
flist{4} = NewList;
[~, maxIdx{4}] = max(AccuList);
figure(4);
plot(AccuList);
title('tone quality');                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

% how important is each feature
W = zeros(size(AccuList,2), 4);
for i = 1:4
    [~, W(:, i)] = sort(flist{i});
end
W = 136-W;

% see the feature set with best performance
for i = 1:4
    set{i} = flist{i}(1:maxIdx{i});
end

