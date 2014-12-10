function ltisys = pdcontroller()

ROLL_KP = 3.5;
PITCH_KP = 3.5;
YAW_KP = 0.0;
ROLL_RATE_KP = 35;
PITCH_RATE_KP = 35;
YAW_RATE_KP = 30;

Z_KP = 10000;
Z_RATE_KP = 1400;

K = [0 0 -Z_KP 0 PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 PITCH_RATE_KP YAW_RATE_KP;
     0 0 -Z_KP ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP ROLL_RATE_KP 0 -YAW_RATE_KP;
     0 0 -Z_KP 0 -PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 -PITCH_RATE_KP YAW_RATE_KP;
     0 0 -Z_KP -ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP -ROLL_RATE_KP 0 -YAW_RATE_KP];

ltisys = LinearSystem([],[],[],[],[],K);

%if (all(x0==0))
%  ltisys = setInputFrame(ltisys,p.getStateFrame);
%else
%  ltisys = setInputFrame(ltisys,CoordinateFrame([p.getStateFrame.name,' - ', mat2str(x0,3)],length(x0),p.getStateFrame.prefix));
%  p.getStateFrame.addTransform(AffineTransform(p.getStateFrame,ltisys.getInputFrame,eye(length(x0)),-x0));
%  ltisys.getInputFrame.addTransform(AffineTransform(ltisys.getInputFrame,p.getStateFrame,eye(length(x0)),+x0));
%end

%p.getInputFrame.addTransform(AffineTransform(p.getInputFrame,ltisys.getOutputFrame,eye(4),-20000*ones(4,1)));
%ltisys.getOutputFrame.addTransform(AffineTransform(ltisys.getOutputFrame,p.getInputFrame,eye(4),20000*ones(4,1)));

%angle_flag = [0 0 0 1 1 1 0 0 0 1 1 1]';
%ltisys = setInputFrame(ltisys,ltisys.getInputFrame().constructFrameWithAnglesWrapped(angle_flag));

end