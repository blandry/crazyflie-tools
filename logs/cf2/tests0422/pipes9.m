function [d imFnames]=pipes9()
full_fname = 'pipes9.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipes9.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
