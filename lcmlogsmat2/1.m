function [d imFnames]=1()
full_fname = 'lcmlogsmat2/1';
fname = '/home/blandry/code/drake-crazyflie-tools/lcmlogsmat2/1';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
