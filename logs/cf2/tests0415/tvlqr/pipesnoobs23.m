function [d imFnames]=pipesnoobs23()
full_fname = 'pipesnoobs23.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0415/tvlqr/pipesnoobs23.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
