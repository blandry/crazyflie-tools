clear cf;
cf = Crazyflie();
%ctvlqr = cf.getTvlqr(xtraj,utraj,false);
ctvlqr = cf.getPositionControlTvlqr(xtraj,utraj);
cf.runController(ctvlqr);