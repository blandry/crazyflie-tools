ramps = [64000,64000,64000,64000];
amps = [2000,1000,1000,1000];
freqs = [0,0,0,0];

utraj = getUtraj(ramps,amps,freqs);

cf = Crazyflie();
cf.run(utraj);