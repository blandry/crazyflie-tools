function [d imFnames]=pipesnoobs12()
full_fname = 'pipesnoobs12.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0422/pipesnoobs12.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
