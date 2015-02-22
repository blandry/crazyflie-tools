function [d imFnames]=imuandviconoffboard()
full_fname = 'flights0218/imuandviconoffboard.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/flights0218/imuandviconoffboard.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
