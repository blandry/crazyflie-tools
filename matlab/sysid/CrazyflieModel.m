function [xdot,y] = CrazyflieModel(t,x,uopen,Ixxyy,Izz,Ixy,Kf,Km,varargin)
% States:
% x
% y
% z
% phi (roll)
% theta (pitch)
% psi (yaw)
% xdot
% ydot
% zdot
% phidot
% thetadot
% psidot
%
% Inputs:
% omega^2 for each rotor

% Known parameters
g = 9.81;
m = 0.03337; % mass in Kg
L = 0.046; % Distance from rotor to COM (in m)

% Unknown parameters
Ixx = 2.15e-006*Ixxyy;
Iyy = 2.15e-006*Ixxyy;
Izz = 4.29e-006*Izz;
Ixy = 2.37e-007*Ixy;
Kf = 0.005022393588278*Kf;
Km = -1.400164274777642e-06*Km;

I = [Ixx Ixy 0; Ixy Iyy 0; 0 0 Izz]; % Inertia matrix
invI = inv(I);

% states
phi = x(4);
theta = x(5);
psi = x(6);

phidot = x(10);
thetadot = x(11);
psidot = x(12);

% Rotation matrix from body to world frames
[R,dR] = rpy2rotmat([phi;theta;psi]);
Rdot = reshape(dR(:,1)*phidot+dR(:,2)*thetadot+dR(:,3)*psidot,3,3);

% angular vel in base frame
pqr = rpydot2angularvel([phi;theta;psi],[phidot;thetadot;psidot]); 

% angular vel in body frame
pqr = R'*pqr;

ROLL_KP = .7;
PITCH_KP = .7;
YAW_KP = 0;
ROLL_RATE_KP = .8;
PITCH_RATE_KP = .8;
YAW_RATE_KP = .6;
K = [0,0,0,0,PITCH_KP,YAW_KP,0,0,0,0,PITCH_RATE_KP,YAW_RATE_KP;
     0,0,0,ROLL_KP,0,-YAW_KP,0,0,0,ROLL_RATE_KP,0,-YAW_RATE_KP;
     0,0,0,0,-PITCH_KP,YAW_KP,0,0,0,0,-PITCH_RATE_KP,YAW_RATE_KP;
     0,0,0,-ROLL_KP,0,-YAW_KP,0,0,0,-ROLL_RATE_KP,0,-YAW_RATE_KP];
ufb = K*[x(1:9);pqr];

% K = [5.0000 0.0000 -4.3301 0.0137 7.4915 2.5000 2.7635 -0.0025 -3.7928 0.0038 1.0343 2.2539;
%      0.0000 -5.0000 -4.3301 7.4915 0.0137 -2.5000 0.0025 -2.7635 -3.7928 1.0343 0.0038 -2.2539;
%      -5.0000 -0.0000 -4.3301 -0.0137 -7.4915 2.5000 -2.7635 0.0025 -3.7928 -0.0038 -1.0343 2.2539;
%      -0.0000 5.0000 -4.3301 -7.4915 -0.0137 -2.5000 -0.0025 2.7635 -3.7928 -1.0343 -0.0038 -2.2539];
% ufb = K*x + repmat(16.2950-15,4,1);

u = uopen' + ufb;

%u = min(u,40.87);

% These are omega^2
w1 = u(1);
w2 = u(4);
w3 = u(3);
w4 = u(2);

% Thrust = kf*omega^2
F1 = Kf*w1; 
F2 = Kf*w2;
F3 = Kf*w3;
F4 = Kf*w4;

% Moments = km*omega^2
M1 = Km*w1;
M2 = Km*w2;
M3 = Km*w3;
M4 = Km*w4;

xyz_ddot = (1/m)*([0;0;-m*g] + R*[0;0;F1+F2+F3+F4]);

% angular acceleration in body frame
pqr_dot = invI*([L*(F2-F4);L*(F3-F1);(M1-M2+M3-M4)]-cross(pqr,I*pqr));

% Now, convert pqr_dot to rpy_ddot
[Phi, dPhi] = angularvel2rpydotMatrix([phi;theta;psi]);
Phidot = reshape(dPhi(:,1)*phidot+dPhi(:,2)*thetadot+dPhi(:,3)*psidot,3,3);

rpy_ddot = Phidot*R*pqr + Phi*Rdot*pqr + Phi*R*pqr_dot;

xdot = [x(7:12);xyz_ddot;rpy_ddot];

%y = [x(1:3);pqr];
y = x(1:6);

end