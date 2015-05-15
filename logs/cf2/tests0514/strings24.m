function [d imFnames]=strings24()
full_fname = 'strings24.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0514/strings24.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
