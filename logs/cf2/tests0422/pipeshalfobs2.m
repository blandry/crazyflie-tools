function [d imFnames]=pipeshalfobs2()
full_fname = 'pipeshalfobs2.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipeshalfobs2.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
