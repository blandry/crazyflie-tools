function [d imFnames]=lcmlog_2015_03_24_02()
full_fname = 'lcmlog_2015_03_24_02.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0324/lcmlog_2015_03_24_02.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
