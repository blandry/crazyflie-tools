function hoverOpenLoop()
Kf = 1.426531127550046e-09;
a = -1.499999942623626e+04;
m = 22.4;
u = sqrt(m/(4*Kf))+a;
fprintf('Quad input: %d\n',u);
utraj = ConstantTrajectory(repmat(u,4,1));
cf = Crazyflie();
cf.run(utraj);
end

