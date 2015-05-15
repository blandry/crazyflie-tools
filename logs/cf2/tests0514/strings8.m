function [d imFnames]=strings8()
full_fname = 'strings8.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0514/strings8.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
