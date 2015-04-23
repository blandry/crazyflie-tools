function [d imFnames]=pipesnoobs3()
full_fname = 'pipesnoobs3.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipesnoobs3.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
