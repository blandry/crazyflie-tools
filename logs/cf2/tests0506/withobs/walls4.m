function [d imFnames]=walls4()
full_fname = 'walls4.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0506/withobs/walls4.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
