function [d imFnames]=pipes27()
full_fname = 'pipes27.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipes27.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
