function [d imFnames]=roundtripproblem()
full_fname = 'logs/cf2/tests0315/roundtripproblem.mat';
fname = '/home/blandry/code/crazyflie-tools/logs/cf2/tests0315/roundtripproblem.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
