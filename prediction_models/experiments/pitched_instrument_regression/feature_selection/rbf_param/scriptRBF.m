% script rbf param
c_list = [0.001 0.01 0.1 1 10 100 1000];
g_list = 1/32*c_list;

for i = 1:7
    c = c_list(i);
    for j = 1:7
        g = g_list(j);
        for idx = 1
            rbf(c, g, idx);
        end
    end
end