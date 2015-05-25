function [d imFnames]=forest6()
full_fname = 'forest6.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0506/withobs/forest6.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
