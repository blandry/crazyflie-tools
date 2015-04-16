function [d imFnames]=pipesnoobs8()
full_fname = 'pipesnoobs8.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0415/tvlqr/pipesnoobs8.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
