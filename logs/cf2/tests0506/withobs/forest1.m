function [d imFnames]=forest1()
full_fname = 'forest1.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0506/withobs/forest1.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
