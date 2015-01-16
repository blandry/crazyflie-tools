% The time intervals to use
% Use plotlog to identify those
T = [5.075 5.384;
     4.942 5.242;
     5.351 5.868;
     4.342 4.717;
     3.483 4.167;
     3.8 4.334;
     4.275 4.792;
     4.717 5.167;
     3.634 4.192];

for i=1:size(T,1)
  t0 = T(i,1);
  tf = T(i,2);
  rawdata = load([num2str(i) '.mat']);

  pos = rawdata.crazyflie_squ_ext;
  input = rawdata.crazyflie_input;

  [~,ipos]=min(abs(pos(:,8)-t0));
  [~,jpos]=min(abs(pos(:,8)-tf));
  t0pos = pos(ipos,8);
  tfpos = pos(jpos,8);

  [~,iinput]=min(abs(input(:,6)-(t0pos-.5)));
  [~,jinput]=min(abs(input(:,6)-(tfpos+.5)));
  input1foh = foh(input(iinput:jinput,6)',input(iinput:jinput,2)');
  input2foh = foh(input(iinput:jinput,6)',input(iinput:jinput,3)');
  input3foh = foh(input(iinput:jinput,6)',input(iinput:jinput,4)');
  input4foh = foh(input(iinput:jinput,6)',input(iinput:jinput,5)');
  input1 = ppval(input1foh,pos(ipos:jpos,8));
  input2 = ppval(input2foh,pos(ipos:jpos,8));
  input3 = ppval(input3foh,pos(ipos:jpos,8));
  input4 = ppval(input4foh,pos(ipos:jpos,8));

  % Transform of input and states here
  timestamps = pos(ipos:jpos,8);
  N = numel(timestamps);
  % shift the input because of lcm, scale them for easy modeling
  inputdata = ([input1,input2,input3,input4]+32768)/10000;

  posdata = [pos(ipos:jpos,2:4),zeros(N,3)];
  ang = pos(ipos:jpos,5:7);
  for t=1:N
    % transform the euler angles because of vicon
    posdata(t,4:6) = quat2rpy(angle2quat(ang(t,1),ang(t,2),ang(t,3),'XYZ'));
  end
  % unwrap the angles for better idea of dynamics
  posdata(:,4:6) = unwrap(posdata(:,4:6));
  
  data = [timestamps,inputdata,posdata];
  save(['clean' num2str(i) '.mat'],'data');
end

% you can remove some experiments from the sysid here
% ex: files = [1 3 4]
%files = 1:size(T,1);
%files = [5];
%files = [1 2 3 4 5 7 8 9];

% for the inertia matrix
files = [1 2 3];

d = cell(1,numel(files));
for i=1:numel(files)
  
  % Load clean data
  load (['clean' num2str(files(i)) '.mat']);
  t = data(:,1);
  udata = data(:,2:5);
  xdata = data(:,6:11);

  % omega = u - a
  % model expects omega^2 as input
  a = -1.208905335853438;
  omega = udata - a;
  udata = omega.^2;

  % Fit PPtrajectory 
  xdata = PPTrajectory(spline(t,xdata'));
  udata = PPTrajectory(spline(t,udata'));

  % Sample at uniform rate
  dt = 1/120;
  t_sample = t(1):dt:t(end); 
  inputs = udata.eval(t_sample); % Control inputs
  outputs = xdata.eval(t_sample); % Configuration space variables
  sysiddata = iddata(outputs',inputs',dt);
  set(sysiddata,'InputName',{'thrust1','thrust2','thrust3','thrust4'},'OutputName',{'x','y','z','roll','pitch','yaw'});

  d{i} = sysiddata;
end

z = merge(d{:});

% Shift data to take into account delay
% (delay is 42ms, and sample rate 120Hz)
delay = 5*ones(1,4);
z = nkshift(z,delay); 

save('sysidData.mat','z');