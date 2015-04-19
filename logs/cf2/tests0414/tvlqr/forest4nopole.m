function [d imFnames]=forest4nopole()
full_fname = 'forest4nopole.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0414/tvlqr/forest4nopole.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
