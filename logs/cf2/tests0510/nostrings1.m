function [d imFnames]=nostrings1()
full_fname = 'nostrings1.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0510/nostrings1.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
