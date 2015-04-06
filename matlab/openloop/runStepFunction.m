usamples = [zeros(4,100),35000*ones(4,100),zeros(4,100)];
steptraj = PPTrajectory(zoh(linspace(0,3,300),usamples));
cf = Crazyflie();
cf.run(steptraj);