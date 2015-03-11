function [xtraj,utraj,prog] = runDircol(cf)

% simple planning demo which takes the quadrotor from hover at x=0m to a new hover at
% x=2m with minimal thrust.

N = 31;
minimum_duration = .1;
maximum_duration = 4;
prog = DircolTrajectoryOptimization(cf.manip,N,[minimum_duration maximum_duration]);  

x0 = Point(getStateFrame(cf.manip));
x0.base_x = 1.0;
x0.base_z = 1.5;
u0 = double(cf.nominal_input);

prog = prog.addStateConstraint(ConstantConstraint(double(x0)),1);
prog = prog.addInputConstraint(ConstantConstraint(u0),1);

xf = x0;
xf.base_x = 4;
prog = prog.addStateConstraint(ConstantConstraint(double(xf)),N);
prog = prog.addInputConstraint(ConstantConstraint(u0),N);

prog = prog.addRunningCost(@(t,x,u)cost(t,x,u,cf));
prog = prog.addFinalCost(@(t,x)finalCost(t,x,cf));

tf0 = 2;
traj_init.x = PPTrajectory(foh([0,tf0],[double(x0),double(xf)]));
traj_init.u = ConstantTrajectory(u0);

info=0;
while (info~=1)
  tic
  [xtraj,utraj,z,F,info] = prog.solveTraj(tf0,traj_init);
  toc
end

if (nargout<1)
  v = constructVisualizer(cf.manip);
  v.playback(xtraj,struct('slider',true));
end

end

function [g,dg] = cost(dt,x,u,cf)
  R = eye(4);
  g = u'*R*u;
  dg = [0,zeros(1,size(x,1)),2*u'*R];
end

function [h,dh] = finalCost(t,x,cf)
  h = 5*t;
  dh = [5,zeros(1,size(x,1))];
end