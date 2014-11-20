function [xdot,y] = SBachModel(t,x,u,Jx_fac,Jy_fac,Jz_fac,wing_z_drag_fac,body_drag_fac,stab_force_fac,thr_fac,thr_to_sp_ail,thr_to_sp_elev,body_y_drag_fac,yaw_torque_fac1,elev_lift_fac,yaw_torque_fac2,roll_torque_fac,pitch_torque_fac,pitch_torque_fac_orig,varargin)

% function [xdot,y] = SBachModel(t,x,u,wing_z_drag_fac,body_drag_fac,stab_force_fac,thr_fac,thr_to_sp_ail,thr_to_sp_elev,body_y_drag_fac,yaw_torque_fac1,elev_lift_fac,yaw_torque_fac2,roll_torque_fac,pitch_torque_fac,pitch_torque_fac_orig,varargin)



% Set output (first six states)
y = x(1:6);


% @param t time
% @param x state: x =
%  Plane's X coordinate faces forward, Y to the right, and Z down.
%  x(1):x    (Forward Position, Earth frame)
%  x(2):y    (East or y position, Earth frame)
%  x(3):z     (z position (down), Earth frame)
%  x(4):phi   (roll Euler angle)
%  x(5):theta (pitch Euler angle)
%  x(6):psi   (yaw Euler angle)
%  x(7):U     (X-velocity, body frame)
%  x(8):V     (Y-velocity, body frame)
%  x(9):W     (Z-velocity, body frame)
%  x(10):P    (Angular Rate Vector of roll, body frame)
%  x(11):Q    (Angular Rate Vector of pitch, body frame)
%  x(12):R    (Angular Rate Vector of yaw, body frame)
%
%  u(1):thr   (Throttle command)
%  u(2):ail   (Aileron Command)
%  u(3):elev  (Elevator Command)
%  u(4):rud   (Rudder command)

% Parameters fit from data
% Jx_fac = 0.9516;
% Jy_fac = 1.5273; 
% Jz_fac = 1.1388;
% wing_z_drag_fac = 0; % -25.257278373275717;
% body_drag_fac = 0; %   0.005478206432966;
% stab_force_fac = 1; %   83.600173058683495;
% thr_fac = 0.1861;


thr_vel_fac_elev = 1.0;
thr_vel_fac_ail = 1.0; 
% thr_to_sp_ail = 1.0;
% thr_to_sp_elev = 1.0;
% body_y_drag_fac = 0;
% yaw_torque_fac1 = 1;
% elev_lift_fac = 1;
% yaw_torque_fac2 = 0;
% roll_torque_fac = 0;
% pitch_torque_fac = 0;
% pitch_torque_fac_orig = 1;



thr_drag_fac = 0; % thr_drag_fac*1e-6;

Jx = Jx_fac*.0005; % The numbers are just guesses to get things in the right ball park
Jy = Jy_fac*.0009;
Jz = Jz_fac*.0004;


% Measured parameters (MKS units):
wing_area_out = 7848/(1000*1000);% m^2
wing_area_in = (2.7885*10^3)/(1000*1000); % m^2
wing_total_area = 2*wing_area_out + 2*wing_area_in;
out_dist = 132.8/1000; % Moment arm of outer wing section
in_dist = 46.4/1000; % Moment arm of inner wing section
elev_area = 5406/(1000*1000); % m^2
elev_arm = 240/1000;
rudder_area = (3.80152*1000)/(1000*1000);
rudder_arm = 258.36/1000; % m
stab_area = 923.175/(1000*1000); % m^2
stab_arm = 222/1000; % m
m =  76.6/1000; % kg (with battery in)
g = 9.81; % m/s^2
thr_to_thrust = 1; % 0.1861; % grams per unit throttle command

ail_comm_to_rad = 8.430084159809215e-04; % Multiply raw command by these to get deflection in rads
elev_comm_to_rad = -0.001473692553866; % Sign is correct
rud_comm_to_rad = -0.001846558348610; % Sign is correct

ail_area_out = (4.5718848*10^3)/(1000*1000);
ail_area_in = (1.51275*10^3)/(1000*1000);

thr_min = 270; % If it's less than 270, prop doesn't spin

rho = 1.1839; % kg/m^3 (density of air)

throttle_trim = 250; % At 250, we have 0 propwash speed (according to fit from anemometer readings)
ail_trim = 512;
rud_trim = 512;
elev_trim = 512;

% Dynamics computations after this
Pn = x(1);
Pe = x(2);
Pd = x(3);
% phi = x(4);
% theta = x(5);
% psi = x(6);

%% CHANGE THIS WHEN USING CORRECT ANGLE REP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rpy = quat2rpy(angle2quat(x(4),x(5),x(6),'XYZ')); 
phi = rpy(1);
theta = rpy(2);
psi = rpy(3);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
U = x(7);
V = x(8);
W = x(9);
P = x(10);
Q = x(11);
R = x(12);

R_body_to_world = rpy2rotmat(rpy);
R_world_to_body = R_body_to_world';

% COM velocity in world coordinates
xdots_world = R_body_to_world*[U;V;W];

% Angular velocity in world coordinate frame
omega_world = R_body_to_world*[P;Q;R];

%Throttle signal is 150-850
thr = u(1) - throttle_trim; % Shift it
if thr < (thr_min - throttle_trim)
    thr = 0;
end
% thr = thr_fac*max(thr,0); % Scale it and don't let it go negative

% positive AilL is negative lift (front of aileron tips downwards)
ail = (u(2)-ail_trim)*ail_comm_to_rad; % input in radians of deflection

% NOTE: Figure out signs for these
ailL = ail; % This is correct sign
% Positive ailR is positive lift (front of aileron tips downwards)
ailR = ail; % This is correct sign

%positive elevator is deflection up (negative lift - makes plane
%pitch up)
elev = (u(3)-elev_trim)*elev_comm_to_rad; % input in radians of deflection--check sign

%positive rudder is deflection to the right
rud = (u(4)-rud_trim)*rud_comm_to_rad;% input in radians of deflection


% Now, the hard stuff

% Do translataional stuff first

% Speed of plane
vel = sqrt(U^2 + V^2 + W^2);

% Angle of attack
alpha = atan2(W,U);
% alpha = atan(W,U); % sym

%Sideslip angle
beta = atan2(V,sqrt(vel^2-V^2));
% beta = atan(V,sqrt(vel^2 - V^2)); % sym

% Propwash over ailerons (0.2932 was fit from anemometer experiments)
upa = sqrt((vel^2)/4 + thr_to_sp_ail*0.2932*thr) - vel/2; %

uwa = thr_vel_fac_ail*sqrt(vel^2 + upa^2 + 2*vel*upa*cos(alpha));
alpha_wa = atan2(W,U + upa);
% alpha_wa = atan(W,U + upa);

% Propwash over rudder/elevator (0.1444 was fit from anemometer
% experiments)
upe = sqrt((vel^2)/4 + thr_to_sp_elev*0.1444*thr) - vel/2;


% Elevator position and velocity
% Velocity of elevator in world coordinate frame
xdot_elev = xdots_world + cross(omega_world,[-elev_arm;0;0]);
xdot_elev_body = R_world_to_body*xdot_elev;

alpha_elev = atan2(xdot_elev_body(3),xdot_elev_body(1));

uwe = thr_vel_fac_elev*sqrt(vel^2 + upe^2 + 2*vel*upe*cos(alpha_elev));
alpha_we = atan2(xdot_elev_body(3),xdot_elev_body(1) + upe);
% alpha_we = atan(W,U + upe); % sym

%Lift force generated by wing components. (flat plate)
%lift = dynamic pressure * area * Coefficient of lift.
left_wing_out_lift = pressure(vel) * wing_area_out * Cl_fp_fit(alpha);
left_wing_in_lift = pressure(uwa) * wing_area_in * Cl_fp_fit(alpha_wa);
right_wing_out_lift = pressure(vel) * wing_area_out * Cl_fp_fit(alpha);
right_wing_in_lift = pressure(uwa) * wing_area_in * Cl_fp_fit(alpha_wa);

%Lift force generated by ailerons. (flat plate)
%lift = dynamic pressure * area * Coefficient of lift.
left_ail_out_lift = pressure(vel) * ail_area_out * Cl_fp(alpha-ailL);
left_ail_in_lift = pressure(uwa) * ail_area_in * Cl_fp(alpha_wa-ailL);
right_ail_out_lift = pressure(vel) * ail_area_out * Cl_fp(alpha+ailR);
right_ail_in_lift = pressure(uwa) * ail_area_in * Cl_fp(alpha_wa+ailR);






%include lift terms from flat plate theory of elevator
% lift = left_out_lift + left_in_lift + right_out_lift + right_in_lift;
elev_lift = elev_lift_fac*pressure(uwe) * elev_area * ... likely a small term
    Cl_fp(alpha_we-elev); %angle of deflection of Elevator

% NOTE: Do we need separate inner/outer terms for elevator too?

%Drag force generated by wing components.
left_wing_out_drag = pressure(vel) * wing_area_out * Cd_fp_fit(alpha);
left_wing_in_drag = pressure(uwa) * wing_area_in * Cd_fp_fit(alpha_wa);
right_wing_out_drag = pressure(vel) * wing_area_out * Cd_fp_fit(alpha);
right_wing_in_drag = pressure(uwa) * wing_area_in * Cd_fp_fit(alpha_wa);

%Drag force generated by ailerons.
left_ail_out_drag = pressure(vel) * ail_area_out * Cd_fp(alpha-ailL);
left_ail_in_drag = pressure(uwa) * ail_area_in * Cd_fp(alpha_wa-ailL);
right_ail_out_drag = pressure(vel) * ail_area_out * Cd_fp(alpha+ailR);
right_ail_in_drag = pressure(uwa) * ail_area_in * Cd_fp(alpha_wa+ailR);

%Compute drag on elevator using flat plate theory
elev_drag = pressure(uwa) * elev_area * Cd_fp(alpha_we-elev);

% Drag due to body (in x-direction)
body_drag =  body_drag_fac*pressure(U);

% Drag due to wing in z-direction
body_z_drag = wing_z_drag_fac * pressure(W) * wing_total_area;

% Drag due to body in y-direction
body_y_drag = body_y_drag_fac * pressure(V) * wing_total_area; % Just a rough initial estimate

% Estimated from experiments with digital scale
thrust = thr_fac*thr*thr_to_thrust*9.81/1000;


% Assemble fv
% First gravity
fv = R_world_to_body*[0;0;m*g];
% fv = [-m*g*sin(theta); m*g*sin(phi)*cos(theta); m*g*cos(phi)*cos(theta)];


% Then lift/drag
R_alpha = [-cos(alpha) 0  sin(alpha); ...
    0          1  0         ; ...
    -sin(alpha) 0 -cos(alpha)];

R_alpha_in = [-cos(alpha_wa) 0 sin(alpha_wa); ...
    0             1 0            ; ...
    -sin(alpha_wa) 0 -cos(alpha_wa)];

R_alpha_elev = [-cos(alpha_we) 0 sin(alpha_we); ...
    0             1 0            ; ...
    -sin(alpha_we)  0 -cos(alpha_we)];

fv = fv + R_alpha*[left_wing_out_drag;0;left_wing_out_lift] ... % wing
    + R_alpha_in*[left_wing_in_drag;0;left_wing_in_lift] ... % wing
    + R_alpha*[right_wing_out_drag;0;right_wing_out_lift] ... % wing
    + R_alpha_in*[right_wing_in_drag;0;right_wing_in_lift] ... % wing
    + R_alpha*[left_ail_out_drag;0;left_ail_out_lift] ... % ail
    + R_alpha_in*[left_ail_in_drag;0;left_ail_in_lift] ... % ail
    + R_alpha*[right_ail_out_drag;0;right_ail_out_lift] ... % ail
    + R_alpha_in*[right_ail_in_drag;0;right_ail_in_lift] ... % ail
    + R_alpha_elev*[elev_drag;0;elev_lift]; % elevator


% Finally, add body drag terms
fv = fv - [body_drag;-sign(V)*body_y_drag;-sign(W)*body_z_drag];
% fv = fv - [body_drag;0;(W/abs(W))*body_z_drag]; % sym


% Then rotational stuff

%Roll torque neglects the rolling torque generated by the rudder
roll_torque = (left_ail_out_lift*out_dist + left_ail_in_lift*in_dist)...
    - (right_ail_in_lift*in_dist + right_ail_out_lift*out_dist);

% roll_torque_fac = 1;
roll_torque = roll_torque + roll_torque_fac*0.5*rho*out_dist*in_dist*wing_total_area*upa*P;

roll_torque = roll_torque + thr_drag_fac*thr;

%(Cm*dynamic pressure*wing reference area*average chord)=pitching moment
% .204 is the average chord of the wing
pitch_torque = -elev_lift*elev_arm; % + ...
    % (pressure(U) * Cm(obj,alpha) * wing_total_area * av_chord_wing);

% pitch_torque_fac = 1;
pitch_torque = pitch_torque_fac_orig*pitch_torque + pitch_torque_fac*0.5*rho*(elev_arm^2)*elev_area*upe*Q;


%Stabilizing force from aircraft yawing
stab_force = -stab_force_fac*sign(R) * pressure(R*stab_arm) * (stab_area+rudder_area);
% stab_force = -stab_force_fac*(R/abs(R)) * pressure(R*stab_arm) *
% (stab_area+rudder_area); % sym

%include rudder area in the V term of the stabilizing force?  The
%rudder isn't always perpendicular to V, but it is close most of
%the time.
%stabilizing force from sideslip
% stab_force = stab_force - sign(V)*pressure(V)*stab_area*1.2;
% stab_force = stab_force - (V/abs(V))*pressure(V)*stab_area*1.2;
% sym

% Sideslip angle for rudder
beta_rud = atan2(V,sqrt(vel^2-V^2) + upe); % Assuming propwash over rudder is same as elevator

% Rudder force flat plate
rudder_force_l = -pressure(uwe) * rudder_area * Cl_fp(beta_rud + rud);
rudder_force_d = -pressure(uwe) * rudder_area * Cd_fp(beta_rud + rud);


yaw_torque = stab_force * stab_arm + yaw_torque_fac1*rudder_force * -rudder_arm;

yaw_torque = yaw_torque + yaw_torque_fac2*0.5*rho*(rudder_arm^2)*rudder_area*upe*R;

% Put equations together
% Kinematics
Pn_dot = U * cos(theta)*cos(psi) + ...
    V*(-cos(phi)*sin(psi) + sin(phi)*sin(theta)*cos(psi)) +...
    W*(sin(phi)*sin(psi) + cos(phi)*sin(theta)*cos(psi));
Pe_dot = U * cos(theta)*sin(psi) + ...
    V*(cos(phi)*cos(psi) + sin(phi)*sin(theta)*sin(psi)) +...
    W*(-sin(phi)*cos(psi) + cos(phi)*sin(theta)*sin(psi));
h_dot = -U*sin(theta) + V*sin(phi)*cos(theta) + W*cos(phi)*cos(theta);
phi_dot = P + tan(theta)*(Q*sin(phi) + R*cos(phi));
theta_dot = Q*cos(phi) - R*sin(phi);
psi_dot = (Q*sin(phi) + R*cos(phi))/cos(theta);
% Dynamics
Sw = [0 -R Q; R 0 -P;-Q P 0];
UVW_dot = -Sw*[U;V;W] + fv/m + [1;0;0]*thrust/m;
U_dot = UVW_dot(1);
V_dot = UVW_dot(2);
W_dot = UVW_dot(3);


P_dot = (Jy-Jz)*R*Q/Jx + roll_torque/Jx;
Q_dot = (Jz-Jx)*P*R/Jy + pitch_torque/Jy;
R_dot =  yaw_torque/Jz+(Jx-Jy)*P*Q/Jz;

xdot = [Pn_dot Pe_dot h_dot phi_dot theta_dot psi_dot U_dot V_dot...
    W_dot P_dot Q_dot R_dot]';


end

function cl = Cl_fp(a) % Flat plate model
if a > pi/2
    a = pi/2;
elseif a<-pi/2
    a = -pi/2;
end

cl = 2*sin(a)*cos(a);

end

function cd = Cd_fp(a) % Flat plate
if a > pi/2
    a = pi/2;
elseif a<-pi/2
    a = -pi/2;
end

cd = 2*(sin(a)^2);

end

function cl = Cl_fp_fit(a) % Flat plate model with correction terms
if a > pi/2
    a = pi/2;
elseif a<-pi/2
    a = -pi/2;
end

% These numbers were fit from no-throttle experiments
cl = 2*sin(a)*cos(a) + 0.5774*sin(3.0540*a);

end

function cd = Cd_fp_fit(a) % Flat plate with correction terms
if a > pi/2
    a = pi/2;
elseif a<-pi/2
    a = -pi/2;
end

% These numbers were fit from no-throttle experiments
cd = 2*(sin(a)^2) - 0.1027*(sin(a)^2) + 0.1716;

end


% function cm = Cm(obj,a) % xfoil
% if a > pi/2
%     a = pi/2;
% elseif a<-pi/2
%     a = -pi/2;
% end
% 
% cm = ppval(obj.Cmpp, a*180/pi);
% end

function pre = pressure(vel) %Dynamic Pressure = .5 rho * v^2
pre = .5 * 1.1839 * vel^2; % N/m^2
end

