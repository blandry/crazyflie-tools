function [d imFnames]=alphaequal1only()
full_fname = 'logs/cf2/kalmanTesting0316/round3/alphaequal1only.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/kalmanTesting0316/round3/alphaequal1only.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
