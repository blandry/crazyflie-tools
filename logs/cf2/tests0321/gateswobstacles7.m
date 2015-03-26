function [d imFnames]=gateswobstacles7()
full_fname = 'gateswobstacles7.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0321/gateswobstacles7.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
