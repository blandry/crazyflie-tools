clear cf;
cf = Crazyflie();
ctvlqr = cf.getTvlqr(xtraj,utraj,false);
cf.runController(ctvlqr);