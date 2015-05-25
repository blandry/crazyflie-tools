function [d imFnames]=strings4()
full_fname = 'strings4.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0510/strings4.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
