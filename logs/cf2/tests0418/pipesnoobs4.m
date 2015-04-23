function [d imFnames]=pipesnoobs4()
full_fname = 'pipesnoobs4.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0418/pipesnoobs4.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
