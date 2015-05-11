function [d imFnames]=strings9()
full_fname = 'strings9.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0510/strings9.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
