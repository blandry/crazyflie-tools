ramps = [57000,56000,55000,55000];
amps = [500,500,2000,2000];
freqs = [4,4,1,1];

utraj = getUtraj(ramps,amps,freqs);

cf = Crazyflie();
cf.run(utraj);