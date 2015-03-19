function [d imFnames]=tvlqrgates2()
full_fname = 'tvlqrgates2.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0318/tvlqrgates2.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
