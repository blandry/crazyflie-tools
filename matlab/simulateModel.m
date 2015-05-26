plant = CrazyflieModel();
u0 = [0 0 .1 0 0 0 plant.nominal_thrust]';
utraj = ConstantTrajectory(u0);
utraj = utraj.setOutputFrame(plant.getInputFrame);
sys = cascade(utraj,plant);
systraj = sys.simulate([0 5],[0 0 1 0 0 0 0 0 0 0 0 0]');

T = AffineTransform(systraj.getOutputFrame,plant.manip.getStateFrame,eye(12),zeros(12,1));
frame = systraj.getOutputFrame();
frame.addTransform(T);
systraj.setOutputFrame(plant.manip.getStateFrame);
v = plant.manip.constructVisualizer();
v.playback(systraj,struct('slider',true));

figure(65)
xx = systraj.eval(systraj.getBreaks())';
plot(xx(:,4:6));
legend('roll','pitch','yaw');