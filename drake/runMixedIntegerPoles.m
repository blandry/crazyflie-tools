AUTOSAVE = true;

cf = Crazyflie();
r = cf.manip;

terrain = RigidBodyFlatTerrain();
terrain = terrain.setGeometryColor([.1 .1 .1]');
r = r.setTerrain(terrain);

dt = .5;
degree = 3;
n_segments = 7;
start = [0;0;1];
goal = [3;0;1.5];

r = addRobotFromURDF(r, 'poles.urdf');

lb = [-1;-1;.1];
ub = [4;1;3];

seeds = [...
         start';
         goal';
         ]';
n_regions = 7;

[ytraj,v] = runMixedIntegerEnvironment(r, start, goal, lb, ub, seeds, degree, n_segments, n_regions, dt);

% % Invert differentially flat outputs to find the state traj
disp('Inverting differentially flat system...')
ytraj = ytraj.setOutputFrame(DifferentiallyFlatOutputFrame);
[xtraj, utraj] = invertFlatOutputs(r,ytraj);
disp('done!');

figure(83);
clf
hold on
ts = utraj.getBreaks();
ts = linspace(ts(1), ts(end), 100);
u = utraj.eval(ts);
plot(ts, u(1,:), ts, u(2,:), ts, u(3,:), ts, u(4,:))
drawnow()

v.playback(xtraj, struct('slider', true));

% % Stabilize the trajectory with TVLQR
% x0 = xtraj.eval(0);
% tf = utraj.tspan(2);
% Q = cf.tvQ;
% R = cf.tvR;
% Qf = cf.tvQ;
% disp('Computing stabilizing controller with TVLQR...');
% c = tvlqr(r,xtraj,utraj,Q,R,Qf);
% sys = feedback(r,c);
% disp('done!');
% % sys = cascade(utraj, r);
% 
% % Simulate the result
% disp('Simulating the system...');
% xtraj_sim = simulate(sys,[0 tf],x0);
% disp('done!');

if AUTOSAVE
  folder = fullfile('data', datestr(now,'yyyy-mm-dd_HH.MM.SS'));
  system(sprintf('mkdir -p %s', folder));
  save(fullfile(folder, 'results.mat'), 'xtraj', 'ytraj', 'utraj');
end

% % Draw the result
% xtraj_sim = xtraj_sim.setOutputFrame(r.getStateFrame());
% v.playback(xtraj_sim, struct('slider', true));

lc = lcm.lcm.LCM.getSingleton();
lcmgl = drake.util.BotLCMGLClient(lc, 'quad_trajectory');
lcmgl.glBegin(lcmgl.LCMGL_LINES);
lcmgl.glColor3f(0.0,0.0,1.0);

breaks = ytraj.getBreaks();
ts = linspace(breaks(1), breaks(end));
Y = squeeze(ytraj.eval(ts));
for i = 1:size(Y, 2)-1
  lcmgl.glVertex3f(Y(1,i), Y(2,i), Y(3,i));
  lcmgl.glVertex3f(Y(1,i+1), Y(2,i+1), Y(3,i+1));
end

% figure(123)
% clf
% hold on
% Ysnap = fnder(ytraj, 4);
% Ysn = squeeze(Ysnap.eval(ts));
% plot(ts, sum(Y.^2, 1), ts, sum(Ysn.^2, 1))

lcmgl.glEnd();
lcmgl.switchBuffers();