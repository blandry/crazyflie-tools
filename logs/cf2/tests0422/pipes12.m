function [d imFnames]=pipes12()
full_fname = 'pipes12.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipes12.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
