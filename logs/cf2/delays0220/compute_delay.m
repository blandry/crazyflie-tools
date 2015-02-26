input_func = PPTrajectory(foh(crazyflie_input(:,7)',crazyflie_input(:,2)'));
hold on
format long
plot(crazyflie2_delay(:,8),crazyflie2_delay(:,7));
plot(crazyflie2_delay(:,8),input_func.eval(crazyflie2_delay(:,8))/10000,'g');
%ylim([0 1]);
%xlim([1000 2000])
