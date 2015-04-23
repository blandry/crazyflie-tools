function [d imFnames]=pipesnoobs6()
full_fname = 'pipesnoobs6.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0418/pipesnoobs6.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
