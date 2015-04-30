function [d imFnames]=pipes41()
full_fname = 'pipes41.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0422/pipes41.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
