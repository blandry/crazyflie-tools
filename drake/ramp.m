
cf = Crazyflie();

t = linspace(0,3,100);
u = repmat(linspace(0,60000,numel(t)),4,1);
utraj = PPTrajectory(spline(t,u));

cf.run(utraj);
