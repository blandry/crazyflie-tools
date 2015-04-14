ytraj = scaleTime(ytraj,2);
ytraj = ytraj.setOutputFrame(DifferentiallyFlatOutputFrame);
[xtraj,utraj] = invertFlatOutputs(cf.manip,ytraj);