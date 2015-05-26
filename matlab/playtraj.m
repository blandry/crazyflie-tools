t0 = xtraj.tspan(1);
tf = xtraj.tspan(2);

x = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),2:13)';
t = crazyflie_state_estimate((crazyflie_state_estimate(:,14)>t0)&(crazyflie_state_estimate(:,14)<tf),14)';
logtraj = PPTrajectory(spline(t,x));

options.floating = true;
r = RigidBodyManipulator('crazyflie.urdf',options);
%r = r.addRobotFromURDF('crazyflie.urdf',[],[],options);

%fulltraj = vertcat(xtraj(1:6,:),logtraj(1:6,:),xtraj(7:12,:),logtraj(7:12,:));

%fulltraj = setOutputFrame(fulltraj,getStateFrame(r));
logtraj = setOutputFrame(logtraj,getStateFrame(r));
xtraj = setOutputFrame(xtraj,getStateFrame(r));

v = r.constructVisualizer();
%v.playback(fulltraj,struct('slider',true));
%v.playback(logtraj,struct('slider',true));
v.playback(xtraj,struct('slider',true));