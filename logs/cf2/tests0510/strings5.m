function [d imFnames]=strings5()
full_fname = 'strings5.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0510/strings5.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
