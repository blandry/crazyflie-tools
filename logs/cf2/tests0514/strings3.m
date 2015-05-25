function [d imFnames]=strings3()
full_fname = 'strings3.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0514/strings3.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
