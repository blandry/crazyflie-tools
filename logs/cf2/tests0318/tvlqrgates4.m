function [d imFnames]=tvlqrgates4()
full_fname = 'tvlqrgates4.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0318/tvlqrgates4.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
