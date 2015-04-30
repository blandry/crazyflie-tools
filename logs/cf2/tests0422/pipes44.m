function [d imFnames]=pipes44()
full_fname = 'pipes44.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0422/pipes44.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
