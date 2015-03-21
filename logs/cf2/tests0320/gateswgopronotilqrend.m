function [d imFnames]=gateswgopronotilqrend()
full_fname = 'gateswgopronotilqrend.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0320/gateswgopronotilqrend.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
