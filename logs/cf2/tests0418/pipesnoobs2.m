function [d imFnames]=pipesnoobs2()
full_fname = 'pipesnoobs2.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0418/pipesnoobs2.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
