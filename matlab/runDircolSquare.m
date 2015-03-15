function [xtraj,utraj,prog] = runDircolSquare()

cf = Crazyflie();

N = 60;
minimum_duration = .1;
maximum_duration = 6;
prog = DircolTrajectoryOptimization(cf.manip,N,[minimum_duration maximum_duration]);  

x0 = Point(getStateFrame(cf.manip));
x0.base_x = 0;
x0.base_y = -1.0;
x0.base_z = 1.25;
u0 = double(cf.nominal_input);
prog = prog.addStateConstraint(ConstantConstraint(double(x0)),1);
prog = prog.addInputConstraint(ConstantConstraint(u0),1);

x1 = x0;
x1.base_x = 3;
prog = prog.addStateConstraint(ConstantConstraint(double(x1)),round(N/4));

x2 = x1;
x2.base_y = 1.0;
prog = prog.addStateConstraint(ConstantConstraint(double(x2)),round(N/2));

x3 = x2;
x3.base_x = 0;
prog = prog.addStateConstraint(ConstantConstraint(double(x3)),round(3*N/4));

xf = x3;
xf.base_y = -1.0;
prog = prog.addStateConstraint(ConstantConstraint(double(xf)),N);
prog = prog.addInputConstraint(ConstantConstraint(u0),N);

prog = prog.addRunningCost(@cost);
prog = prog.addFinalCost(@finalCost);

tf0 = 4;
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

function [g,dg] = cost(dt,x,u)
  R = eye(4);
  g = u'*R*u;
  dg = [0,zeros(1,size(x,1)),2*u'*R];
end

function [h,dh] = finalCost(t,x)
  h = t;
  dh = [1,zeros(1,size(x,1))];
end
