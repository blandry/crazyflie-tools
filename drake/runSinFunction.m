f1 = 1;
f2 = 2;
f3 = 3;
f4 = 4;

A1 = 10000;
A2 = 10000;
A3 = 10000;
A4 = 10000;

t = linspace(0,2,200);

u1 = A1*sin(2*pi*f1*t);
u2 = A2*sin(2*pi*f2*t);
u3 = A3*sin(2*pi*f3*t);
u4 = A4*sin(2*pi*f4*t);
utraj = PPTrajectory(spline(t,[u1;u2;u3;u4]);

cf = Crazyflie();

while (1)
  cf.run(utraj,'omegasqu');
end