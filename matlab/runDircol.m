function [xtraj,utraj,prog] = runDircol()

cf = CrazyflieModel();

N = 11;
minimum_duration = .1;
maximum_duration = 4;
prog = DircolTrajectoryOptimization(cf,N,[minimum_duration maximum_duration]);  

x0 = Point(getStateFrame(cf.manip));
x0.base_x = 0;
x0.base_z = .4;
u0 = [0 0 0 0 0 0 cf.nominal_thrust]';

prog = prog.addStateConstraint(ConstantConstraint(double(x0)),1);
prog = prog.addInputConstraint(ConstantConstraint(u0),1);

xf = x0;
xf.base_x = 1;
prog = prog.addStateConstraint(ConstantConstraint(double(xf)),N);
prog = prog.addInputConstraint(ConstantConstraint(u0),N);

prog = prog.addRunningCost(@cost);
prog = prog.addFinalCost(@finalCost);

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
  xtraj = xtraj.setOutputFrame(cf.manip.getStateFrame);      
  v.playback(xtraj,struct('slider',true));
end

end

function [g,dg] = cost(dt,x,u)
  R = eye(7);
  g = u'*R*u;
  dg = [0,zeros(1,size(x,1)),2*u'*R];
end

function [h,dh] = finalCost(t,x)
  h = t;
  dh = [1,zeros(1,size(x,1))];
end