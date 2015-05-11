function [d imFnames]=strings1_1()
full_fname = 'strings1_1.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0509/strings1_1.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
