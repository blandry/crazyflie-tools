t0 = xtraj.tspan(1);
tf = xtraj.tspan(2);

x = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),2:13)';
t = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),14)';

xref = xtraj.eval(xtraj.getBreaks());
tref = xtraj.getBreaks();

figure(5);
hold on
plot(tref,xref(1,:),'b');
plot(t,x(1,:),'r');
legend('reference','actual');
title('x vs time');

figure(6);
hold on
plot(tref,xref(2,:),'b');
plot(t,x(2,:),'r');
legend('reference','actual');
title('y vs time');

figure(7);
hold on
plot(tref,xref(3,:),'b');
plot(t,x(3,:),'r');
legend('reference','actual');
title('z vs time');

figure(8);
hold on
plot(-xref(2,:),xref(1,:),'b');
plot(-x(2,:),x(1,:),'r');
legend('reference','actual');
title('position (x vs -y)');