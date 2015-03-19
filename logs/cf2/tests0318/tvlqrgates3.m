function [d imFnames]=tvlqrgates3()
full_fname = 'tvlqrgates3.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0318/tvlqrgates3.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
