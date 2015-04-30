function [d imFnames]=forest4()
full_fname = 'forest4.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0415/tvlqr/forest4.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
