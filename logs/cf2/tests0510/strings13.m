function [d imFnames]=strings13()
full_fname = 'strings13.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0510/strings13.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
