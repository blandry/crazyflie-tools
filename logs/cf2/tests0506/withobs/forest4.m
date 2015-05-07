function [d imFnames]=forest4()
full_fname = 'forest4.mat';
fname = '/home/drc/code/crazyflie-tools/logs/cf2/tests0506/withobs/forest4.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
