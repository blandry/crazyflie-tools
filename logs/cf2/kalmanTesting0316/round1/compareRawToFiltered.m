x_raw = crazyflie2_squ_ext(:,4);
t_raw = crazyflie2_squ_ext(:,8);
dx_raw = diff(x_raw)./(1/130);%diff(t_raw);
dx_raw = PPTrajectory(spline(t_raw(2:end),dx_raw));

dx_filt = crazyflie_state_estimate(:,10);
t_filt = crazyflie_state_estimate(:,15);
dx_filt = PPTrajectory(spline(t_filt,dx_filt));

plot(t_raw,dx_raw.eval(t_raw),t_filt,dx_filt.eval(t_filt))
legend('raw','filtered')
