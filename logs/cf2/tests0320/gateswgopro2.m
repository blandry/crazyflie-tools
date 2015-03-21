function [d imFnames]=gateswgopro2()
full_fname = 'gateswgopro2.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0320/gateswgopro2.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
