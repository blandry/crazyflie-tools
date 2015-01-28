function playdata(file_num)

file = load(['clean' num2str(file_num) '.mat']);

t = file.data(:,1);
u = file.data(:,2:5);
q = file.data(:,6:11);
xtraj = PPTrajectory(spline(t,q'));

cf = Crazyflie();
v = cf.manip.constructVisualizer();
v = setInputFrame(v,getOutputFrame(xtraj));
v.playback(xtraj,struct('slider',true));

end