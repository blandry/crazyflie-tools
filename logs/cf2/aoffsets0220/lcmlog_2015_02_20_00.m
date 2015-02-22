function [d imFnames]=lcmlog_2015_02_20_00()
full_fname = 'aoffsets0220/lcmlog_2015_02_20_00.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/aoffsets0220/lcmlog_2015_02_20_00.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
