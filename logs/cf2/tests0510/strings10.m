function [d imFnames]=strings10()
full_fname = 'strings10.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0510/strings10.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
