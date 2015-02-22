function [d imFnames]=imuonlyoffboard()
full_fname = 'logs/cf2/flights0218/imuonlyoffboard.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/flights0218/imuonlyoffboard.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
