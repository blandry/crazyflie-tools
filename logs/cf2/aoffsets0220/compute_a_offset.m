input_func = PPTrajectory(foh(crazyflie_input(:,7)',crazyflie_input(:,2)'));
yaw = crazyflie2_delay(:,7);

dyaw = diff(yaw);
tcrit = crazyflie2_delay(end,7);
for i=1:size(crazyflie2_delay,1)
  if (abs(dyaw(i))>0.005)
    tcrit = crazyflie2_delay(i,8);
    break
  end
end
a_offset = input_func.eval(tcrit);
format long
display(a_offset);

hold on
plot(dyaw);
plot(input_func.eval(crazyflie2_delay(:,8))/10000,'g');
%ylim([0 1]);
%xlim([1000 2000])