function [d imFnames]=pipes4()
full_fname = 'pipes4.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0423/pipes4.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
