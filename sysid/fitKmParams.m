function fitKmParams(crazyflie_input,crazyflie_state_estimate,t0,tf,lower_bound,upper_bound)

if (nargin<3)
  t0 = -Inf;
end
if (nargin<4)
  tf = Inf;
end
if (nargin<5)
  lower_bound = -Inf;
end
if (nargin<6)
  upper_bound = Inf;
end

Ixx=2.15e-006;
Iyy=2.15e-006;
Izz=4.29e-006;
Ixy=2.37e-007; 

input = PPTrajectory(spline(crazyflie_input(:,7),(crazyflie_input(:,2:5)+repmat(crazyflie_input(:,6),1,4))'));

% butterworth filter gyroz
[b,a] = butter(1,.2);
crazyflie_state_estimate(:,13) = filtfilt(b,a,crazyflie_state_estimate(:,13));

rdot = zeros(size(crazyflie_state_estimate,1),1);
w = zeros(size(crazyflie_state_estimate,1),1);
e = zeros(size(crazyflie_state_estimate,1),1);
for i=2:size(rdot,1)
  p = crazyflie_state_estimate(i,11);
  q = crazyflie_state_estimate(i,12);
  t = crazyflie_state_estimate(i,14);
  
  u = input.eval(t);
  w(i) = u(2)+u(4)-u(1)-u(3);
  e(i) = (p*(Ixy*p+Iyy*q)+q*(Ixx*p+Ixy*q))/Izz;
  
  if (w(i)>lower_bound && w(i)<upper_bound && t>=t0 && t<=tf)
    rdot(i) = (1/(crazyflie_state_estimate(i,14)-crazyflie_state_estimate(i-1,14)))*(crazyflie_state_estimate(i,13)-crazyflie_state_estimate(i-1,13));
  else
    w(i) = 0;
    e(i) = 0;
  end
end
datawzeros = [w, e, rdot];

data = [];
for i=1:size(datawzeros,1)
 if (norm(datawzeros(i,:)')>0)
  data = [data;datawzeros(i,:)];
 end
end

x0 = 1E-6;
Kf = fmincon(@(x)modelfit(x,data),x0,-1,0,[],[],[],[],[],struct('Display','off'));
display(Kf);

% plot the final model
hold on
[X,Y] = meshgrid(linspace(min(data(:,1))-1,max(data(:,1))+1,100),linspace(min(data(:,2))-1,max(data(:,2))+1,100));
Z = zeros(size(X));
for i=1:size(X,2)
  fakedata = [X(:,i),Y(:,i)];
  Z(:,i) = evalparams(Kf,fakedata);
end
surf(X,Y,Z);
scatter3(data(:,1),data(:,2),data(:,3),[],data(:,3),'filled');
xlabel('net omega squared');
ylabel('net x and y correction factor');
zlabel('z axis acceleration');
title('Final model predictions');

end

function c = modelfit(Km,data)
  rdotpredict = evalparams(Km,data(:,1:2));
  drdot = rdotpredict-data(:,3);
  c = drdot'*drdot;
end

function rdotpredict = evalparams(Km,data)
  Izz = 4.29e-006;
  w = data(:,1);
  e = data(:,2);
  rdotpredict = (1/Izz)*(Km*w)-e;
end