function [d imFnames]=tvlqrgates5()
full_fname = 'tvlqrgates5.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0318/tvlqrgates5.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
