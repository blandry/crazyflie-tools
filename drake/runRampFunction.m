usamples = [zeros(4,100),repmat(linspace(0,65000,100),4,1)];
steptraj = PPTrajectory(foh(linspace(0,4,200),usamples));
cf = Crazyflie();
cf.run(steptraj);