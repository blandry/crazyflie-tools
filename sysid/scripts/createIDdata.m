
N = 12;

d = cell(1,N);
for i=1:N
  % Load clean data
  load ([num2str(i) '.mat']);
  t = data(:,1);
  udata = data(:,2:5);
  xdata = data(:,6:11);

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

  inputs = udata.eval(t_sample); % Control inputs
  outputs = xdata.eval(t_sample); % Configuration space variables
  
  sysiddata = iddata(outputs',inputs',dt);

  d{i} = sysiddata;
end

z = merge(d{:});
save('sysIdDataAll.mat','z')
