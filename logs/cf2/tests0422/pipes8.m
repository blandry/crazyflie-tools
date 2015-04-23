function [d imFnames]=pipes8()
full_fname = 'pipes8.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipes8.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
