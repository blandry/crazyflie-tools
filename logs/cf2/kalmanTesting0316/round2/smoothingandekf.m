function [d imFnames]=smoothingandekf()
full_fname = 'logs/cf2/kalmanTesting0316/round2/smoothingandekf.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/kalmanTesting0316/round2/smoothingandekf.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
