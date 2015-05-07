function [d imFnames]=pipes6()
full_fname = 'pipes6.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0506/pipes6.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
