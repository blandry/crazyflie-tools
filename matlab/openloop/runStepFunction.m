usamples = [zeros(4,100),65000*ones(4,100)];
steptraj = PPTrajectory(zoh(linspace(0,2,200),usamples));
cf = Crazyflie();
cf.run(steptraj);