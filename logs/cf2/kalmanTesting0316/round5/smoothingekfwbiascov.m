function [d imFnames]=smoothingekfwbiascov()
full_fname = 'logs/cf2/kalmanTesting0316/round5/smoothingekfwbiascov.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/kalmanTesting0316/round5/smoothingekfwbiascov.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
