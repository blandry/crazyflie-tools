function [d imFnames]=lcmlog_2015_04_09_00()
full_fname = 'lcmlog_2015_04_09_00.mat';
fname = '/Users/pflomacpro/crazyflie-tools/vortex/logs/testing0409/40galzooka/lcmlog_2015_04_09_00.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
