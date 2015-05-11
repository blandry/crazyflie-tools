function [d imFnames]=strings1()
full_fname = 'strings1.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0510/strings1.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
