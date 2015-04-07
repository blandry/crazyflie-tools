function plotlog(file_num)

data = load(strcat(num2str(file_num),'.mat'));

tpos = data.crazyflie_state_estimate(:,15);
pos = [data.crazyflie_state_estimate(:,2:4),data.crazyflie_state_estimate(:,5:7)];

%tinput = data.crazyflie_input(:,7);
%input = data.crazyflie_input(:,2:6);
tinput = data.crazyflie_extra_input(:,7);
input = data.crazyflie_extra_input(:,2:6);

subplot(2,1,1);

pos(:,4:6) = unwrap(pos(:,4:6));
f = PPTrajectory(spline(tpos,pos(:,1:6)'));
plot(tpos,f.eval(tpos));
legend('x','y','z','r','p','y');

subplot(2,1,2);
plot(tinput,input);
title('Input over time');

end

