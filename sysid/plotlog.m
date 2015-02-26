function plotlog(file_num)

data = load(strcat(num2str(file_num),'.mat'));

tpos = data.crazyflie_state_estimate(:,14);
pos = [data.crazyflie_state_estimate(:,2:4),data.crazyflie_state_estimate(:,11:13)];

tinput = data.crazyflie_input(:,7);
input = data.crazyflie_input(:,2:5);

subplot(2,1,1);
plot(tpos,pos(:,1:3));
title('Position and gyro rates over time');
%legend('x','y','z','rolld','pitchd','yawd');
ylim([-5 5]);

subplot(2,1,2);
plot(tinput,input);
title('Input over time');

end

