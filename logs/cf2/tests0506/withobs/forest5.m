function [d imFnames]=forest5()
full_fname = 'forest5.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0506/withobs/forest5.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
