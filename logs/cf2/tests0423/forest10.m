function [d imFnames]=forest10()
full_fname = 'forest10.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0423/forest10.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
