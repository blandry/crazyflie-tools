% The time intervals to use
% Use plotlog to identify those
T = [
12 12.5;%10.81 12.71;
19.66 21.57;
15.82 16.57;
];

for i=1:size(T,1)
  t0 = T(i,1);
  tf = T(i,2);
  rawdata = load([num2str(i) '.mat']);

  pos = [rawdata.crazyflie_state_estimate(:,2:4),rawdata.crazyflie_state_estimate(:,11:13),rawdata.crazyflie_state_estimate(:,15)];
  input = [rawdata.crazyflie_input(:,2:5)+repmat(rawdata.crazyflie_input(:,6),1,4),rawdata.crazyflie_input(:,7)];
  t = rawdata.crazyflie_state_estimate(:,15);
  
  input1zoh = PPTrajectory(zoh(input(:,5),input(:,1)));
  input2zoh = PPTrajectory(zoh(input(:,5),input(:,2)));
  input3zoh = PPTrajectory(zoh(input(:,5),input(:,3)));
  input4zoh = PPTrajectory(zoh(input(:,5),input(:,4)));
  input1 = input1zoh.eval(t);
  input2 = input2zoh.eval(t);
  input3 = input3zoh.eval(t);
  input4 = input4zoh.eval(t);

  posdata = pos(:,1:6);
  inputdata = [input1,input2,input3,input4];
  
  data = [t,inputdata,posdata];
  save(['clean' num2str(i) '.mat'],'data');
end

% you can remove some experiments from the sysid here
% ex: files = [1 3 4]
%files = 1:size(T,1);
file = [1];

d = cell(1,numel(files));
for i=1:numel(files)
  
  % Load clean data
  load (['clean' num2str(files(i)) '.mat']);
  t = data(:,1);
  udata = data(:,2:5);
  xdata = data(:,6:11);

  % Fit PPtrajectory 
  xdata = PPTrajectory(spline(t,xdata'));
  udata = PPTrajectory(zoh(t,udata'));

  % Sample at uniform rate
  dt = 1/100;
  t_sample = t(1):dt:t(end); 

  inputs = udata.eval(t_sample);
  
  xyzoutputs = xdata.eval(t_sample);
  xyzoutputs = xyzoutputs(1:3,:);
  
  % you can shift the gyro w.r.t vicon here
  gyrooutputs = xdata.eval(t_sample);
  gyrooutputs = gyrooutputs(4:6,:);

  outputs = [xyzoutputs;gyrooutputs];
  
  sysiddata = iddata(outputs',inputs',dt);
  set(sysiddata,'InputName',{'thrust1','thrust2','thrust3','thrust4'},'OutputName',{'x','y','z','gyrox','gyroy','gyroz'});
  
  d{i} = sysiddata;
end

z = merge(d{:});

% Shift data to take into account delay
% (delay is 42ms)
delay = round(0.042/dt);
z = nkshift(z,delay*ones(1,4));

save('sysidData.mat','z');