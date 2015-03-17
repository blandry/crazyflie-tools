function [d imFnames]=ekf()
full_fname = 'logs/cf2/kalmanTesting0316/ekf.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/kalmanTesting0316/ekf.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
