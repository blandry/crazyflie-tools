
% raw = [raw_pos; zeros(6,1) diff(raw_pos,1,2)*120];

figure(25);
hold on

plot(raw(3,:)','g');

plot(raw(7:9,:)','b');
plot(estimates(7:9,:)','r');

%ylim([-15 15]);

xtraj = PPTrajectory(spline(linspace(0,size(estimates,2)*(1/120),size(estimates,2)),estimates(1:6,:)));