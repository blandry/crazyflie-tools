function [d imFnames]=forest12()
full_fname = 'forest12.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0415/tvlqr/forest12.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
