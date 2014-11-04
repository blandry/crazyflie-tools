function runKf()
Fs = 10000:5000:60000;
dt = 1;
cf = Crazyflie();
for i=1:numel(Fs)
    fprintf('Input signal: %d\n',Fs(i))
    utraj = ConstantTrajectory(repmat(Fs(i),4,1));
    cf.run(utraj,[0 dt]);
    utraj = ConstantTrajectory(zeros(4,1));
    cf.run(utraj,[0 dt]);
end
end

