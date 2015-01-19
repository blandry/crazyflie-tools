function plotdata(file_num)

file = load(['clean' num2str(file_num) '.mat']);

t = file.data(:,1);
u = file.data(:,2:5);
q = file.data(:,6:11);

subplot(2,1,2);
plot(t,q);
title('Position over time');
legend('x','y','z','roll','pitch','yaw');

subplot(2,1,1);
plot(t,u);
title('Input over time');

end

