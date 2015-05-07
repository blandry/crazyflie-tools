function [d imFnames]=walls1()
full_fname = 'walls1.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0506/walls1.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
