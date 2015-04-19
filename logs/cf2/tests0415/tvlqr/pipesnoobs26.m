function [d imFnames]=pipesnoobs26()
full_fname = 'pipesnoobs26.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0415/tvlqr/pipesnoobs26.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
