function [d imFnames]=forest8nopole()
full_fname = 'forest8nopole.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0414/tvlqr/forest8nopole.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
