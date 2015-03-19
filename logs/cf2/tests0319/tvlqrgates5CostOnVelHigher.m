function [d imFnames]=tvlqrgates5CostOnVelHigher()
full_fname = 'tvlqrgates5CostOnVelHigher.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0319/tvlqrgates5CostOnVelHigher.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
