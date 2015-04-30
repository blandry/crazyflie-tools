function [d imFnames]=forest6()
full_fname = 'forest6.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0423/forest6.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
