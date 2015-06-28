cf = Crazyflie;
c = cf.getPositionControlTilqr([1  0  0.4 zeros(1,9)]');
cf.runController(c);