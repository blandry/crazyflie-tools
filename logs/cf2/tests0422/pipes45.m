function [d imFnames]=pipes45()
full_fname = 'pipes45.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipes45.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
