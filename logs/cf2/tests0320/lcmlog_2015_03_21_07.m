function [d imFnames]=lcmlog_2015_03_21_07()
full_fname = 'lcmlog_2015_03_21_07.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0320/lcmlog_2015_03_21_07.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
