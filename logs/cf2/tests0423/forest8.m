function [d imFnames]=forest8()
full_fname = 'forest8.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0423/forest8.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
