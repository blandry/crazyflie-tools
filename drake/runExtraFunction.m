% inputs are in omega_square

% exp1
f1 = 1;
f2 = 1;
f3 = 1;
f4 = 1;
A1 = 5;
A2 = 0;
A3 = 5;
A4 = 0;
u0 = 0;

t = linspace(0,5,500);
u1 = A1*sin(2*pi*f1*t);
u2 = A2*sin(2*pi*f2*t);
u3 = A3*sin(2*pi*f3*t);
u4 = A4*sin(2*pi*f4*t);
utraj = PPTrajectory(spline(t,[u1;u2;u3;u4]+u0));

cf = Crazyflie();

while (1)
  cf.run(utraj,'omegasqu');
end