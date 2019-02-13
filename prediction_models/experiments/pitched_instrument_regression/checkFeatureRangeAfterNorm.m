function outOfRange = checkFeatureRangeAfterNorm(file2013, file2014, file2015, ifpYin)

DATA_PATH = 'experiments/pitched_instrument_regression/data/';
if ifpYin == 1
    DATA_PATH = 'experiments/pitched_instrument_regression/dataPyin/';
end
root_path = deriveRootPath();
full_data_path = [root_path DATA_PATH];

load([full_data_path file2013]);
features2013 = features(:, 1:22);
load([full_data_path file2014]);
features2014 = features(:, 1:22);
load([full_data_path file2015]);
features2015 = features(:, 1:22);

clear features;

[train1, test1] = NormalizeFeatures([features2013; features2014], features2015);
[train2, test2] = NormalizeFeatures([features2013; features2015], features2014);
[train3, test3] = NormalizeFeatures([features2014; features2015], features2013);

test = [test3; test2; test1];
outOfRange = (test>1) | (test<0); % 17th feature: binDiff in IOI
%outOfRange = (test>1.1) | (test<-0.1);
%outOfRange = (test>1.2) | (test<-0.2);
% the two out of range points are the 188th (2.3849) and 258th (2.9047) (they belong to 2014)

