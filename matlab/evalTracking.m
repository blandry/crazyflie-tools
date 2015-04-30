t0 = xtraj.tspan(1);
tf = xtraj.tspan(2);

x = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),2:13)';
t = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),14)';

xref = xtraj.eval(xtraj.getBreaks());
tref = xtraj.getBreaks();

% col = 'red';
% 
% figure(22)
% 
% subplot(3,2,1)
% hold on
% plot(tref,xref(1,:),'b');
% plot(t,x(1,:),col);
% legend('reference','actual');
% title('x vs time');
% ylim([-2 2]);
% 
% subplot(3,2,2)
% hold on
% plot(tref,xref(2,:),'b');
% plot(t,x(2,:),col);
% legend('reference','actual');
% title('y vs time');
% ylim([-1 1]);
% 
% subplot(3,2,3)
% hold on
% plot(tref,xref(3,:),'b');
% plot(t,x(3,:),col);
% legend('reference','actual');
% title('z vs time');
% 
% subplot(3,2,4)
% hold on
% plot(-xref(2,:),xref(1,:),'b');
% plot(-x(2,:),x(1,:),col);
% legend('reference','actual');
% title('position (x vs -y)');
% xlim([-2,2]);
% ylim([-2,2]);
% 
% subplot(3,2,5)
% hold on
% plot(xref(1,:),xref(3,:),'b');
% plot(x(1,:),x(3,:),col);
% legend('reference','actual');
% title('position (z vs x)');
% xlim([-2,2]);
% ylim([0,3]);
% 
% subplot(3,2,6)
% hold on
% plot(tref,xref(4,:),'b',tref,xref(5,:),'b');
% plot(t,x(4,:),col,t,x(5,:),col);
% title('roll and pitch vs time');

% figure(23)
% 
% ureft = utraj.getBreaks();
% uref = utraj.eval(ureft);
% ut = crazyflie_input(:,7)';
% u = crazyflie_input(:,2:5)'+15;
% hold on
% plot(ureft,uref(4,:),'b');
% plot(ut,u(4,:),'r');

figure(66)
hold on
trunc = 90;
trunc2 = 30;
plot(tref(1:end-trunc),xref(1:3,1:end-trunc),'-.');
plot(t(1:end-trunc2),x(1:3,1:end-trunc2),'LineWidth',2);
legend('x reference','y reference','z reference','x actual','y actual','z actual');
xlabel('time (s)');
ylabel('position (m)');
title('Position of the quadrotor over time');

figure(67)
hold on
plot(-xref(2,:),xref(1,:),'-.');
plot(-x(2,:),x(1,:),'LineWidth',2);
legend('reference','actual');
xlabel('y position (m)');
ylabel('x position (m)');
title('Trajectory Tracking');
axis equal

figure(68)
hold on
trunc2 = 40;
xrefsamp = xtraj.eval(t(1:end-trunc2));
plot(t(1:end-trunc2),x(1:3,1:end-trunc2)-xrefsamp(1:3,:),'.');
legend('x error','y error','z errpr');
xlabel('time (s)');
ylabel('error (m)');
title('Error of the quadrotor over time');
