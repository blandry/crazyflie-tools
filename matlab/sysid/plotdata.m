function plotdata(file_num)

file = load(['clean' num2str(file_num) '.mat']);

t = file.data(:,1);
u = file.data(:,2:5);
x = file.data(:,6:11);

figure(25);

subplot(2,1,2);
plot(t,x);
title('Position and gyro rates over time');
legend('x','y','z','rolldot','pitchdot','yawdot');

subplot(2,1,1);
plot(t,u);
title('Input over time');
legend('m1','m2','m3','m4');

end

