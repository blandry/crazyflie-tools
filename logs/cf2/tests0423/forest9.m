function [d imFnames]=forest9()
full_fname = 'forest9.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0423/forest9.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
