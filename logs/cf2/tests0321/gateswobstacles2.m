function [d imFnames]=gateswobstacles2()
full_fname = 'gateswobstacles2.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0321/gateswobstacles2.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
