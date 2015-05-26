

options.floating = true;
r = RigidBodyManipulator('crazyflie.urdf',options);
%r = addRobotFromURDF(r, 'strings.urdf');
v = r.constructVisualizer();

lc = lcm.lcm.LCM.getSingleton();
lcmgl = drake.util.BotLCMGLClient(lc, 'quad_log');

t0 = xtraj.tspan(1);
tf = xtraj.tspan(2);

%x = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),2:13)';
%t = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),14)';
%logtraj = PPTrajectory(spline(t,x));

%breaks = logtraj.getBreaks();
%ts = linspace(breaks(1), breaks(end), 1000);
%Y = squeeze(logtraj.eval(ts));
%for i = 1:size(Y, 2)-1
%  lcmgl.glVertex3f(Y(1,i), Y(2,i), Y(3,i));
%  lcmgl.glVertex3f(Y(1,i+1), Y(2,i+1), Y(3,i+1));
%end

%lcmgl.glColor3f(0.0,0.0,1.0);

xtraj = setOutputFrame(xtraj,getStateFrame(r));
v.playback(xtraj,struct('slider',true));

pause;

for i=1:numel(safe_regions)
    region = safe_regions(i);
    drawLCMPolytope(region.A, region.b, i, false, lc);
end

lcmgl.glEnd();
lcmgl.switchBuffers();

pause;

drawLCMPolytope(0, 0, 0, 0, lc);

pause;

lcmgl.glBegin(lcmgl.LCMGL_LINES);
lcmgl.glColor3f(0.0,1.0,0.0);
breaks = xtraj.getBreaks();
ts = linspace(breaks(1), breaks(end), 1000);
Y = squeeze(xtraj.eval(ts));
for i = 1:size(Y, 2)-1
  lcmgl.glVertex3f(Y(1,i), Y(2,i), Y(3,i));
  lcmgl.glVertex3f(Y(1,i+1), Y(2,i+1), Y(3,i+1));
end
lcmgl.glEnd();
lcmgl.switchBuffers();