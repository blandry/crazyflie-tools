function [d imFnames]=walls1()
full_fname = 'walls1.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0506/withobs/walls1.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
