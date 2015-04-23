function [d imFnames]=pipesnoobs9()
full_fname = 'pipesnoobs9.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0418/pipesnoobs9.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
