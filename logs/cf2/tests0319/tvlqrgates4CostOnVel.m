function [d imFnames]=tvlqrgates4CostOnVel()
full_fname = 'tvlqrgates4CostOnVel.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0319/tvlqrgates4CostOnVel.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
