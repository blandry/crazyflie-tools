function [d imFnames]=pipes30()
full_fname = 'pipes30.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipes30.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
