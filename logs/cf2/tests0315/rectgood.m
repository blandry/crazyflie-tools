function [d imFnames]=rectgood()
full_fname = 'logs/cf2/tests0315/rectgood.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0315/rectgood.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
