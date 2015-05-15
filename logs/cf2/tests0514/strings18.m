function [d imFnames]=strings18()
full_fname = 'strings18.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0514/strings18.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
