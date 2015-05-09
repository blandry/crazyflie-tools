function [d imFnames]=pipes2()
full_fname = 'pipes2.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0506/pipes2.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
