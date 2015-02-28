% assumes you just ran processData


Ixx = 2.15;
Iyy = 2.15;
Izz = 4.29;
Ixy = 2.37;
Km = 1;
sol = ode45(@(t,y)CrazyflieModel(t,y,udata.eval(t),Ixx,Iyy,Izz,Ixy,Km),[t(1) t(end)],[outputs(1:3,1);zeros(6,1);outputs(4:6,1)]);
%sol = ode45(@(t,y)sodynamics(t,y(1:6),y(7:12),udata.eval(t)),[t(1) t(end)],[outputs(1:3,1);zeros(6,1);outputs(4:6,1)]);

y = sol.y;

figure(26);

subplot(2,1,2);
plot(sol.x,[y(1:3,:);y(10:12,:)]');
title('Position and gyro rates over time');
legend('x','y','z','rolldot','pitchdot','yawdot');

subplot(2,1,1);
plot(sol.x,udata.eval(sol.x));
title('Input over time');
legend('m1','m2','m3','m4');

%figure(36);
%y = sol.y;
%plot([y(4:6,:);udata.eval(sol.x)]');
%legend('r','p','y','m1','m2','m3','m4')