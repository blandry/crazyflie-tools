function [d imFnames]=tvlqrgates6()
full_fname = 'tvlqrgates6.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0318/tvlqrgates6.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
