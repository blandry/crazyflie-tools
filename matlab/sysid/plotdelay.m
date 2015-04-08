function plotdelay(file_num)

data = load(strcat(num2str(file_num),'.mat'));

tyaw = data.crazyflie2_delay(:,8);
yaw = data.crazyflie2_delay(:,7);
yawtraj = PPTrajectory(spline(tyaw,yaw));

tinput = data.crazyflie_input(:,7);
input = data.crazyflie_input(:,2)/10000;

plot(tinput,input,tinput,yawtraj.eval(tinput));

end
