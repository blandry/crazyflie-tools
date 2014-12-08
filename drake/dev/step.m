
cf = Crazyflie();

t = linspace(0,3,10000);
u1 = zeros(4,4000);
u2 = 40000*[zeros(3,6000);ones(1,6000)];
utraj = PPTrajectory(foh(t,[u1,u2]));

cf.run(utraj);

