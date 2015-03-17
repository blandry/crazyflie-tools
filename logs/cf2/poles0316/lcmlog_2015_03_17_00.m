function [d imFnames]=lcmlog_2015_03_17_00()
full_fname = 'logs/cf2/poles0316/lcmlog_2015_03_17_00.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/poles0316/lcmlog_2015_03_17_00.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
