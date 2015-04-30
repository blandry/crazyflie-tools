function [d imFnames]=forest7()
full_fname = 'forest7.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0415/tvlqr/forest7.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
