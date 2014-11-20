% Load clean data
%data_num = 12;
%load (['../' num2str(data_num) 'clean.mat']);
load('../test.mat');

t = data(:,1);
xdata = data(:,6:11);
udata = data(:,2:5);

% Transform inputs
% omega = u - a.
% Thrust = kf*omega^2.
% Drake model expects omega^2 as input
a = -1.499999942623626e+04;

omega = udata - a;
udata = omega.^2;

% Fit PPtrajectory 
xdata = PPTrajectory(spline(t,xdata'));
udata = PPTrajectory(spline(t,udata'));

% Sample at uniform rate
dt = 1/120; % CHANGE BOTTOM TOO IF YOU CHANGE THIS
t_sample = t(1):dt:t(end); 

qs = xdata.eval(t_sample); % Configuration space variables
outputs = qs;

inputs = udata.eval(t_sample); % Control inputs

% Change this for new log
%zNov05_12 = iddata(outputs',inputs',dt);
%save('sysIdDataAll.mat', ['zNov05' '_' num2str(data_num)], '-append')
testNov05 = iddata(outputs',inputs',dt);
save('sysIdDataAll.mat','testNov05');
