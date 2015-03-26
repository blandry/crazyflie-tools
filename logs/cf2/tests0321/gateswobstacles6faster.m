function [d imFnames]=gateswobstacles6faster()
full_fname = 'gateswobstacles6faster.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0321/gateswobstacles6faster.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
