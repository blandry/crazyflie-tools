%[.15 -.2 1.5];
%[-.2 0 1.25];
%[0 0 1.2];
%[.05 .05 1.1];

AUTOSAVE = true;

cf = Crazyflie();
r = cf.manip;
bot_radius = .08;

%terrain = RigidBodyFlatTerrain();
%terrain = terrain.setGeometryColor([.1 .1 .1]');
%r = r.setTerrain(terrain);

dt = .5;
degree = 3;
n_segments = 7;
n_regions = 15;
% n_segments = 5;
% n_regions = 5;
% n_segments = 7;
% n_regions = 15;
% n_segments = 5;
% n_regions = 5;
% n_segments = 10;
% n_regions = 15;

r = addRobotFromURDF(r, 'strings.urdf');

lb = [-.75 -.5 .8]';
ub = [.75 .5 1.3]';
start = [-.55 -.1 1.1]';
goal = [.55 .25 1.1]';
seeds = [...
        start';
        goal';
        [-.15 .2 1.1];
        [.15 .3 1.1];
        ]';
% lb = [.25 -.5 .8]';
% ub = [.75 .5 2]';
% start = [.55 .25 1.1]';
% goal = [.55 -.25 1.8]';
% seeds = [...
%          start';
%          goal';
%          ]';
% lb = [-.75 -.5 1.4]';
% ub = [.75 .5 1.9]';
% start = [.55 -.25 1.8]';
% goal = [-.55 0 1.5]';
% seeds = [...
%         start';
%         goal';
%         [.25 -.25 1.7];
%         [-.36 0 1.6];
%         ]';
% lb = [-.75 -.5 1]';
% ub = [-.25 .5 1.6]';
% start = [-.55 0 1.5]';
% goal = [-.55 -.1 1.1]';
% seeds = [...
%          start';
%          goal';
%          ]';
% lb = [-.75 -.5 1.1]';
% ub = [0 .5 1.6]';
% start = [-.55 0 1.5]';
% goal = [-.1 .2 1.4]';
% seeds = [...
%         start';
%         goal';
%         %[-.15 .2 1.4];
%         %[0 .2 1.2];
%         ]';
% lb = [-.2 0 1.1]';
% ub = [.5 .5 1.5]';
% start = [-.1 .2 1.4]';
% goal = [.4 .15 1.25]';
% seeds = [...
%         start';
%         goal';
%         ]';
% lb = [.25 -.5 1]';
% ub = [.75 .5 2]';
% start = [.4 .15 1.25]';
% goal = [.55 -.25 1.8]';
% seeds = [...
%          start';
%          goal';
%          ]';

% checkpoints = [
%   -.3 0 1.1;
%   .25 -.2 1.25;
% ];
% ytrajs = cell(1,size(checkpoints,1)-1);
% for i=1:size(checkpoints,1)-1
%   start = checkpoints(i,:)';
%   goal = checkpoints(i+1,:)';
%   seeds = [...
%          start';
%          goal';
%          [0 0 1.1];
%          [-.15 .15 1.1];         
%          ]';
%   [ytraj,v] = runMixedIntegerEnvironment(r, start, goal, lb, ub, seeds, degree, n_segments, n_regions, dt, bot_radius);
%   ytrajs{i} = ytraj;
% end  

[ytraj,v] = runMixedIntegerEnvironment(r, start, goal, lb, ub, seeds, degree, n_segments, n_regions, dt, bot_radius);


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
ts = linspace(ts(1), ts(end), 100);
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