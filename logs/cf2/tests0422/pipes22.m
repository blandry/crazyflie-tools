function [d imFnames]=pipes22()
full_fname = 'pipes22.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0422/pipes22.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
