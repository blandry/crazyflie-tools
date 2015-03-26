function [d imFnames]=lcmlog_2015_03_26_05()
full_fname = 'lcmlog_2015_03_26_05.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0326/lcmlog_2015_03_26_05.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
