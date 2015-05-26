u0 = 16.3683;
%uu = [repmat([0 0 0 0 0 0 u0]',1,100),repmat([1 0 0 0 0 0 u0]',1,100),repmat([-1 0 0 0 0 0 u0]',1,100),repmat([0 1 0 0 0 0 u0]',1,100),repmat([0 -1 0 0 0 0 u0]',1,100),repmat([0 0 0 0 0 0 u0]',1,100)];
%utraj = PPTrajectory(foh(linspace(0,10,size(uu,2)),uu));
uu = [repmat([0 0 0 0 0 0 u0]',1,100),repmat([0 0 pi 0 0 0 u0]',1,100)];
utraj = PPTrajectory(foh(linspace(0,8,size(uu,2)),uu));
cf = Crazyflie();
cf.runPositionControl(utraj);
