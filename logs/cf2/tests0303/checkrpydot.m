
finite_diff = zeros(size(crazyflie_state_estimate,1),3);
for i=2:size(finite_diff,1)
  finite_diff(i,:) = (1/(crazyflie_state_estimate(i,14)-crazyflie_state_estimate(i-1,14)))*(crazyflie_state_estimate(i,5:7)-crazyflie_state_estimate(i-1,5:7));
end

t = crazyflie_state_estimate(:,14);

figure(1)
hold on
plot(t,finite_diff(:,1),'bx-');
plot(t,crazyflie_state_estimate(:,11),'rx-');
ylim([-10 10]);
figure(2)
hold on
plot(t,finite_diff(:,2),'bx-');
plot(t,crazyflie_state_estimate(:,12),'rx-');
ylim([-10 10]);
figure(3)
hold on
plot(t,finite_diff(:,3),'bx-');
plot(t,crazyflie_state_estimate(:,13),'rx-');
ylim([-10 10]);