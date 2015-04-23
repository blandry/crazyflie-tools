function [d imFnames]=pipes18()
full_fname = 'pipes18.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipes18.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
