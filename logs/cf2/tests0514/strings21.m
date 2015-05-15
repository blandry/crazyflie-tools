function [d imFnames]=strings21()
full_fname = 'strings21.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0514/strings21.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
