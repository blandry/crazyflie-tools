function [d imFnames]=pipes73()
full_fname = 'pipes73.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0422/pipes73.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
