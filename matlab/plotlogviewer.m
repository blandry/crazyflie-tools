lc = lcm.lcm.LCM.getSingleton();
lcmgl = drake.util.BotLCMGLClient(lc, 'quad_log');
lcmgl.glBegin(lcmgl.LCMGL_LINES);
lcmgl.glColor3f(1.0,0.0,0.0);

t0 = xtraj.tspan(1);
tf = xtraj.tspan(2)-.6;

x = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),2:13)';
t = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),14)';
logtraj = PPTrajectory(spline(t,x));

breaks = logtraj.getBreaks();
ts = linspace(breaks(1), breaks(end));
Y = squeeze(logtraj.eval(ts));
for i = 1:size(Y, 2)-1
  lcmgl.glVertex3f(Y(1,i), Y(2,i), Y(3,i));
  lcmgl.glVertex3f(Y(1,i+1), Y(2,i+1), Y(3,i+1));
end

%lcmgl.glEnd();
%lcmgl.switchBuffers();

lcmgl.glColor3f(0.0,0.0,1.0);

breaks = xtraj.getBreaks();
ts = linspace(breaks(1), breaks(end));
Y = squeeze(xtraj.eval(ts));
for i = 1:size(Y, 2)-1
  lcmgl.glVertex3f(Y(1,i), Y(2,i), Y(3,i));
  lcmgl.glVertex3f(Y(1,i+1), Y(2,i+1), Y(3,i+1));
end

lcmgl.glEnd();
lcmgl.switchBuffers();

lcmgl.glColor3f(0.0,0.0,1.0);