function fitKm(crazyflie_input,crazyflie_state_estimate)

Ixx=2.15e-006; 
Ixy=2.37e-007; 
Iyy=2.15e-006; 
Izz=4.29e-006;

input = PPTrajectory(spline(crazyflie_input(:,7),(crazyflie_input(:,2:5)+repmat(crazyflie_input(:,6),1,4))'));

alphaz = zeros(size(crazyflie_state_estimate,1),1);
m = zeros(size(crazyflie_state_estimate,1),1);
e = zeros(size(crazyflie_state_estimate,1),1);
for i=2:size(alphaz,1)
  p = crazyflie_state_estimate(i,11);
  q = crazyflie_state_estimate(i,12);
  r = crazyflie_state_estimate(i,13);
  t = crazyflie_state_estimate(i,14);
  
  u = input.eval(t);
  m(i) = u(2)+u(4)-u(1)-u(3);
  e(i) = (p*(Ixy*p+Iyy*q)+q*(Ixx*p+Ixy*q))/Izz;
  
  if (m(i)>10&&m(i)<40)
    alphaz(i) = (1/(crazyflie_state_estimate(i,14)-crazyflie_state_estimate(i-1,14)))*(crazyflie_state_estimate(i,13)-crazyflie_state_estimate(i-1,13));
  else
    m(i) = 0;
    e(i) = 0;
  end
end
datawzeros = [m, e, alphaz];

data = [];
for i=1:size(datawzeros,1)
 if (norm(datawzeros(i,:)')>0)
  data = [data;datawzeros(i,:)];
 end
end

x0 = 0;%1E-6;
Kf = fmincon(@(x)modelfit(x,data),x0,-1,0,[],[],[],[],[],struct('Display','off'));
display(Kf);

% plot the final model
hold on
[X,Y] = meshgrid(min(data(:,1)):max(data(:,1)),min(data(:,2)):max(data(:,2)));
Z = zeros(size(X));
for i=1:size(X,2)
  fakedata = [X(:,i),Y(:,i)];
  Z(:,i) = evalparams(Kf,fakedata);
end
surf(X,Y,Z);
plot3(data(:,1),data(:,2),data(:,3),'ro');
title('Final model predictions');

end

function c = modelfit(Km,data)
  w = evalparams(Km,data(:,1:2));
  dw = w-data(:,3);
  c = dw'*dw;
end

function w = evalparams(Km,data)
  Izz = 4.29e-006;
  m = data(:,1);
  e = data(:,2);
  w = (1/Izz)*(Km*m)-e;
end