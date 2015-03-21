function [d imFnames]=gateswgopro()
full_fname = 'gateswgopro.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0320/gateswgopro.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
