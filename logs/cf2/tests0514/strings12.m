function [d imFnames]=strings12()
full_fname = 'strings12.mat';
fname = '/media/blandry/LinuxData/crazyflie-tools/logs/cf2/tests0514/strings12.mat';
if (exist(full_fname,'file'))
    filename = full_fname;
else
    filename = fname;
end
d = load(filename);
