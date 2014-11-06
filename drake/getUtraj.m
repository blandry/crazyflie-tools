function utraj = getUtraj(ramps,amps,freqs)

Kf = 1.426531127550046e-09;
a = -1.499999942623626e+04;
m = 22.4;
nom = sqrt(m/(4*Kf))+a;

%nom = 1.5*nom;

nom = 60000;

nt = 1000;
tf = 3;
t = linspace(0,tf,nt);

u1 = [linspace(0,ramps(1),0.2*nt),repmat(ramps(1),1,0.05*nt),linspace(ramps(1),0,0.75*nt)+amps(1)*sin(freqs(1)*2*pi*t(1:0.75*nt))];
u2 = [linspace(0,ramps(2),0.2*nt),repmat(ramps(2),1,0.05*nt),linspace(ramps(2),0,0.75*nt)-amps(2)*sin(freqs(2)*2*pi*t(1:0.75*nt))];
u3 = [linspace(0,ramps(3),0.2*nt),repmat(ramps(3),1,0.05*nt),linspace(ramps(3),0,0.75*nt)-amps(3)*sin(freqs(3)*2*pi*t(1:0.75*nt))];
u4 = [linspace(0,ramps(4),0.2*nt),repmat(ramps(4),1,0.05*nt),linspace(ramps(4),0,0.75*nt)-amps(4)*sin(freqs(4)*2*pi*t(1:0.75*nt))];

u = spline(t,[u1;u2;u3;u4]);

utraj = PPTrajectory(u);

end

