function [d imFnames]=lcmlog_2015_04_23_00()
full_fname = 'lcmlog_2015_04_23_00.mat';
fname = '/Users/pflomacpro/crazyflie-tools/logs/cf2/vortex0423/lcmlog_2015_04_23_00.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
