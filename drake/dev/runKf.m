Fs = 10000:5000:60000;
dt = 3;
cf = Crazyflie();
for i=1:numel(Fs)
    fprintf('Input signal: %d\n',Fs(i))
    utraj = ConstantTrajectory([Fs(i);Fs(i);Fs(i);Fs(i)]);
    cf.run(utraj,[0 dt]);
    utraj = ConstantTrajectory(zeros(4,1));
    cf.run(utraj,[0 dt]);
end

