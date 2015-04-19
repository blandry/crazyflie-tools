function [d imFnames]=forest3nopole()
full_fname = 'forest3nopole.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0414/tvlqr/forest3nopole.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
