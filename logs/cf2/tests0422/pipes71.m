function [d imFnames]=pipes71()
full_fname = 'pipes71.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0422/pipes71.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
