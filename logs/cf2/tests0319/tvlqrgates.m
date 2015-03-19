function [d imFnames]=tvlqrgates()
full_fname = 'tvlqrgates.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0319/tvlqrgates.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
