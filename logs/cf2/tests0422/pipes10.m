function [d imFnames]=pipes10()
full_fname = 'pipes10.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipes10.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
