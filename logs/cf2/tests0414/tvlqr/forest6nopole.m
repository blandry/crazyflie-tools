function [d imFnames]=forest6nopole()
full_fname = 'forest6nopole.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0414/tvlqr/forest6nopole.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
