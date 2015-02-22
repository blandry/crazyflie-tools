% The time intervals to use
% Use plotlog to identify those
T = [];

for i=1:size(T,1)
  t0 = T(i,1);
  tf = T(i,2);
  rawdata = load([num2str(i) '.mat']);

  pos = [data.crazyflie_state_estimate(:,2:4),data.crazyflie_state_estimate(:,11:13),rawdata.crazyflie_state_estimate(:,14)];
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
  N = numel(timestamps);
 
  inputdata = [input1,input2,input3,input4];
  posdata = pos(ipos:jpos,1:6)
  % unwrap the angles for better idea of dynamics
  posdata(:,4:6) = unwrap(posdata(:,4:6));
  
  data = [timestamps,inputdata,posdata];
  save(['clean' num2str(i) '.mat'],'data');
end

% you can remove some experiments from the sysid here
% ex: files = [1 3 4]
files = 1:size(T,1);

d = cell(1,numel(files));
for i=1:numel(files)
  
  % Load clean data
  load (['clean' num2str(files(i)) '.mat']);
  t = data(:,1);
  udata = data(:,2:5);
  xdata = data(:,6:11);

  % Fit PPtrajectory 
  xdata = PPTrajectory(spline(t,xdata'));
  udata = PPTrajectory(foh(t,udata'));

  % Sample at uniform rate
  dt = 1/120;
  t_sample = t(1):dt:t(end); 
  inputs = udata.eval(t_sample); % Control inputs
  outputs = xdata.eval(t_sample); % Configuration space variables
  sysiddata = iddata(outputs',inputs',dt);
  set(sysiddata,'InputName',{'thrust1','thrust2','thrust3','thrust4'},'OutputName',{'x','y','z','rolldot','pitchdot','yawdot'});

  d{i} = sysiddata;
end

z = merge(d{:});

% Shift data to take into account delay
% (delay is ?ms, and sample rate 120Hz)
delay = 5*ones(1,4);
z = nkshift(z,delay); 

save('sysidData.mat','z');