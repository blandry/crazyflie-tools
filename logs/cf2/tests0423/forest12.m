function [d imFnames]=forest12()
full_fname = 'forest12.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0423/forest12.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
