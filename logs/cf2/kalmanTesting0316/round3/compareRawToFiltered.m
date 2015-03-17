x_raw = crazyflie2_squ_ext(:,2);
t_raw = crazyflie2_squ_ext(:,8);
dx_raw = diff(x_raw)./(1/120);%diff(t_raw);
%dx_raw = PPTrajectory(spline(t_raw(2:end),dx_raw));

dx_filt = crazyflie_state_estimate(:,8);
t_filt = crazyflie_state_estimate(:,15);
%dx_filt = PPTrajectory(spline(t_filt,dx_filt));

plot(t_raw(2:end),dx_raw,'*r',t_filt,dx_filt,'*g')
legend('raw','filtered')
