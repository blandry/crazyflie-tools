% The time intervals to use
% Use plotlog to identify those
T = [
10.46 11.04;
18.18 18.45;
33.88 34.42;
21.39 21.67;
24.73 25.08;
19.19 19.64;
19.72 20.3;
20.72 21.24;
18.06 18.52;
22.73 23.29;
];

for i=1:size(T,1)
  t0 = T(i,1);
  tf = T(i,2);
  rawdata = load([num2str(i) '.mat']);

  pos = [rawdata.crazyflie_state_estimate(:,2:4),rawdata.crazyflie_state_estimate(:,11:13),rawdata.crazyflie_state_estimate(:,14)];
  input = [rawdata.crazyflie_input(:,2:5),rawdata.crazyflie_input(:,7)];

  [~,ipos]=min(abs(pos(:,7)-t0));
  [~,jpos]=min(abs(pos(:,7)-tf));
  t0pos = pos(ipos,7);
  tfpos = pos(jpos,7);

  [~,iinput]=min(abs(input(:,5)-(t0pos-.5)));
  [~,jinput]=min(abs(input(:,5)-(tfpos+.5)));
  input1foh = foh(input(iinput:jinput,5)',input(iinput:jinput,1)');
  input2foh = foh(input(iinput:jinput,5)',input(iinput:jinput,2)');
  input3foh = foh(input(iinput:jinput,5)',input(iinput:jinput,3)');
  input4foh = foh(input(iinput:jinput,5)',input(iinput:jinput,4)');
  input1 = ppval(input1foh,pos(ipos:jpos,7));
  input2 = ppval(input2foh,pos(ipos:jpos,7));
  input3 = ppval(input3foh,pos(ipos:jpos,7));
  input4 = ppval(input4foh,pos(ipos:jpos,7));

  timestamps = pos(ipos:jpos,7);
  posdata = pos(ipos:jpos,1:6);
  inputdata = [input1,input2,input3,input4];
  
  data = [timestamps,inputdata,posdata];
  save(['clean' num2str(i) '.mat'],'data');
end

% you can remove some experiments from the sysid here
% ex: files = [1 3 4]
%files = 1:size(T,1);
files = [1 2 4 8];

d = cell(1,numel(files));
for i=1:numel(files)
  
  % Load clean data
  load (['clean' num2str(files(i)) '.mat']);
  t = data(:,1);
  udata = data(:,2:5);
  xdata = data(:,6:11);

  % Fit PPtrajectory 
  xdata = PPTrajectory(foh(t,xdata'));
  udata = PPTrajectory(foh(t,udata'));

  % Sample at uniform rate
  dt = 1/100;
  t_sample = t(1):dt:t(end); 

  inputs = udata.eval(t_sample);
  
  xyzoutputs = xdata.eval(t_sample);
  xyzoutputs = xyzoutputs(1:3,:);
  % the gyro is shifted from vicon
  gyrooutputs = xdata.eval(t_sample+.15);
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