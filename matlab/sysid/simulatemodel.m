% assumes you just ran processData

% Ixx = 2.15e-006;
% Iyy = 2.15e-006;
% Izz = 4.29e-006;
% Ixy = 2.37e-007;
% Kf = 0.004522393588278;
% Km = 1.400164274777642e-06;
% 
% sol = ode45(@(t,y)CrazyflieModel(t,y,udata.eval(t),Ixx,Iyy,Izz,Ixy,Kf,Km),[t(1) t(20)],[outputs(1:3,1);zeros(6,1);outputs(4:6,1)]);
% y = sol.y;

utraj = PPTrajectory(spline(crazyflie_input(:,7),crazyflie_input(:,2:5)'+repmat(crazyflie_input(:,6),1,4)'));

n = 90;

cf = Crazyflie();
r = cf.manip;
%udata = setOutputFrame(udata,r.getInputFrame);
utraj = setOutputFrame(utraj,r.getInputFrame);
%sys = cascade(udata,r);
sys = cascade(utraj,r);
%systraj = sys.simulate([t(1) t(n)],[outputs(1:3,1);zeros(6,1);outputs(4:6,1)]);
t0 = utraj.tspan(1);
tf = utraj.tspan(2);
systraj = sys.simulate([t0 tf],xtraj.eval(t0));

tt = t0+1:0.01:tf-1;
sysx = systraj.eval(tt);

figure(26);

plot(tt,[sysx(1:3,:);sysx(10:12,:)]);
legend('x','y','z','rolldot','pitchdot','yawdot');

%hold on
%plot(t(1:n),outputs(1:6,1:n),'*');

% subplot(2,1,2);
% plot(sol.x,[y(1:3,:);y(10:12,:)]');
% title('Position and gyro rates over time');
% legend('x','y','z','rolldot','pitchdot','yawdot');

% subplot(2,1,1);
% plot(sol.x,udata.eval(sol.x));
% title('Input over time');
% legend('m1','m2','m3','m4');

%figure(36);
%y = sol.y;
%plot([y(4:6,:);udata.eval(sol.x)]');
%legend('r','p','y','m1','m2','m3','m4')