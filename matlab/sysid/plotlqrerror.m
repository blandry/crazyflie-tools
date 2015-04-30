T = [
%44.76 46.71;
%49.98 52.49;
%55.93 59.13;
%60.86 62.33;
65.25 68.31;
%72.64 75.72;
];

%xd = [0 0 1.25 0 0 0 0 0 0 0 0 0]';
xd = [0 0 1.25]';

hold on
for i=1:size(T,1)
  t0 = T(i,1);
  tf = t0+3;%T(i,2);
  indexes = crazyflie_state_estimate(:,15)>t0 & crazyflie_state_estimate(:,15)<tf;
  t = crazyflie_state_estimate(indexes,15);
  t = t-t(1);
  x = crazyflie_state_estimate(indexes,2:4)';
  err = sqrt(sum((x - repmat(xd,1,numel(t))).^2,1));
  plot(t,err,'LineWidth',3);
end

title('Position error vs time with LQR controller');
xlabel('time (s)');
ylabel('position error magnitude (L2)');