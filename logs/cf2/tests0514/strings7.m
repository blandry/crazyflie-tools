function [d imFnames]=strings7()
full_fname = 'strings7.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0514/strings7.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
