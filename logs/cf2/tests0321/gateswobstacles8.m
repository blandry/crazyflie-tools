function [d imFnames]=gateswobstacles8()
full_fname = 'gateswobstacles8.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0321/gateswobstacles8.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
