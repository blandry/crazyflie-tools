function [d imFnames]=strings2()
full_fname = 'strings2.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0510/strings2.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
