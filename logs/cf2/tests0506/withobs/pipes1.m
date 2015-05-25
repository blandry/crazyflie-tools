function [d imFnames]=pipes1()
full_fname = 'pipes1.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0506/withobs/pipes1.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
