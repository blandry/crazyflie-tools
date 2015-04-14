clear cf
cf = Crazyflie();
ctilqr=cf.getTilqr([-.4 0 1.25 0 0 0 0 0 0 0 0 0]');
cf.runController(ctilqr)