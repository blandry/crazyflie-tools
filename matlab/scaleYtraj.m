ytraj = scaleTime(ytraj,1.5);
ytraj = ytraj.setOutputFrame(DifferentiallyFlatOutputFrame);
cf = Crazyflie();
[xtraj,utraj] = invertFlatOutputs(cf.manip,ytraj);