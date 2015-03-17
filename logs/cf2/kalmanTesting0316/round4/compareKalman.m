
dx_smooth = dxyz_compare(:,1);
dx_kalman = dxyz_compare(:,4);
t = dxyz_compare(:,7);

plot(t,dx_smooth,'b',t,dx_kalman,'r')
legend('smoothing only','smoothing with kalman')
ylim([-10 10]);