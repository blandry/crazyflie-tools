function [d imFnames]=pipes5()
full_fname = 'pipes5.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0506/pipes5.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
