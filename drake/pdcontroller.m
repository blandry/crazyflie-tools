function ltisys = pdcontroller()
% Reversed engineered from the 
% Crazyflie firmware

Z_KP = 0.0;
ROLL_KP = 3.5 * 180/pi;
PITCH_KP = 3.5 * 180/pi;
YAW_KP = 0.0 * 180/pi;

Z_RATE_KP = 1400;
ROLL_RATE_KP = 35 * 180/pi;
PITCH_RATE_KP = 35 * 180/pi;
YAW_RATE_KP = 30 * 180/pi;

K = 1/10000 * [0 0 -Z_KP 0 PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 PITCH_RATE_KP YAW_RATE_KP;
               0 0 -Z_KP ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP ROLL_RATE_KP 0 -YAW_RATE_KP;
               0 0 -Z_KP 0 -PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 -PITCH_RATE_KP YAW_RATE_KP;
               0 0 -Z_KP -ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP -ROLL_RATE_KP 0 -YAW_RATE_KP];
             
ltisys = LinearSystem([],[],[],[],[],K);

end