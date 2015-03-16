function [d imFnames]=rectekf()
full_fname = 'logs/cf2/tests0315/rectekf.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0315/rectekf.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
