function [d imFnames]=strings20()
full_fname = 'strings20.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0514/strings20.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
