function [d imFnames]=strings6()
full_fname = 'strings6.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0510/strings6.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
