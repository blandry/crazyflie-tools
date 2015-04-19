function [d imFnames]=pipesnoobs28()
full_fname = 'pipesnoobs28.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0415/tvlqr/pipesnoobs28.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
