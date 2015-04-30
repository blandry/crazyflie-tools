function [d imFnames]=forest3()
full_fname = 'forest3.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0423/forest3.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
