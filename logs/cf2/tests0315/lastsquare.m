function [d imFnames]=lastsquare()
full_fname = 'logs/cf2/tests0315/lastsquare.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0315/lastsquare.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
