function [d imFnames]=1()
full_fname = 'lcmlogs/1.mat';
fname = '/home/blandry/code/drake-crazyflie-tools/lcmlogs/1.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
