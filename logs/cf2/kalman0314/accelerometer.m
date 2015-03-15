function [d imFnames]=accelerometer()
full_fname = 'logs/cf2/kalman0314/accelerometer.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/kalman0314/accelerometer.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
