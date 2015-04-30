function [d imFnames]=forest8()
full_fname = 'forest8.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0415/tvlqr/forest8.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
