function [d imFnames]=pipes19()
full_fname = 'pipes19.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipes19.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
