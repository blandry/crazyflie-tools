AUTOSAVE = true;

options.floating = true;
r = RigidBodyManipulator('crazyflie.urdf',options);
r = addRobotFromURDF(r, 'strings.urdf');
v = r.constructVisualizer();

ytrajs = {};
for i=1:8
  data = load(strcat('/media/blandry/LinuxData/crazyflie-tools/matlab/data/strings',int2str(i),'/results.mat'));
  ytrajs{i} = data.ytraj;
end

ytraj = ytrajs{1};
for i=2:numel(ytrajs)
  ytraj = ytraj.append(ytrajs{i}.shiftTime(ytraj.tspan(2)));
end

% % Invert differentially flat outputs to find the state traj
disp('Inverting differentially flat system...')
ytraj = ytraj.setOutputFrame(DifferentiallyFlatOutputFrame);
[xtraj, utraj] = invertFlatOutputs(r,ytraj);
disp('done!');

if AUTOSAVE
  folder = fullfile('data', datestr(now,'yyyy-mm-dd_HH.MM.SS'));
  system(sprintf('mkdir -p %s', folder));
  save(fullfile(folder, 'results.mat'), 'xtraj', 'ytraj', 'utraj');
end

figure(83);
clf
hold on
ts = utraj.getBreaks();
ts = linspace(ts(1), ts(end), 1000);
u = utraj.eval(ts);
plot(ts, u(1,:), ts, u(2,:), ts, u(3,:), ts, u(4,:))
drawnow()

v.playback(xtraj, struct('slider', true));

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