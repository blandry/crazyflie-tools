function [d imFnames]=comparevicontoimu()
full_fname = 'logs/cf2/flights0223/comparevicontoimu.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/flights0223/comparevicontoimu.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
