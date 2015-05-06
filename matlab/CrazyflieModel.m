classdef CrazyflieModel < DrakeSystem
  
  properties
    manip;
    pdK;
    nominal_thrust;
    
    ROLL_KP = 3.5*180/pi;
    PITCH_KP = 3.5*180/pi;
    YAW_KP = 3.5*180/pi;
    ROLL_RATE_KP = 70*180/pi;
    PITCH_RATE_KP = 70*180/pi; 
    YAW_RATE_KP = 50*180/pi;
  end
  
  methods
    function obj = CrazyflieModel()
      obj = obj@DrakeSystem(12,0,7,12,false,true);
      options.floating = true;
      obj.manip = RigidBodyManipulator('crazyflie.urdf',options);
      obj.nominal_thrust = .25*norm(getMass(obj.manip)*obj.manip.gravity)/obj.manip.force{1}.scale_factor_thrust;
      obj.pdK = [0 obj.PITCH_KP obj.YAW_KP 0 obj.PITCH_RATE_KP obj.YAW_RATE_KP;
                 obj.ROLL_KP 0 -obj.YAW_KP obj.ROLL_RATE_KP 0 -obj.YAW_RATE_KP;
                 0 -obj.PITCH_KP obj.YAW_KP 0 -obj.PITCH_RATE_KP obj.YAW_RATE_KP;
                 -obj.ROLL_KP 0 -obj.YAW_KP -obj.ROLL_RATE_KP 0 -obj.YAW_RATE_KP];
    end
    
    function x0 = getInitialState(obj)
      x0 = zeros(12,1);
    end
    
    function [xdot,dxdot] = dynamics(obj,t,x,u)
      % states: xyz, rpy, dxyz, drpy
      % inputs: rpydesired,omegadesired,thrust
      
      [pqr,dpqr] = rpydot2angularvel(x(4:6),x(10:12));
      [R,dR] = rpy2rotmat(x(4:6));
      dR = [dR,zeros(9,3)];      
      dR = blockwiseTranspose(reshape(full(dR),3,[]),[3,3]);
      
      pqr = R'*pqr;
      dpqr = -R'*reshape(dR*pqr,3,[]) + R'*dpqr;
      dpqr = [zeros(3,4) dpqr(:,1:3) zeros(3) dpqr(:,4:6) zeros(3,7)];
      
      err = [x(4:6);pqr]-u(1:6);
      derr = [zeros(3,4),eye(3),zeros(3,13);dpqr]-[zeros(6,13),eye(6),zeros(6,1)];
      motorcommands = obj.pdK*err + sqrt(u(7))*10000.0;
      dmotorcommands = obj.pdK*derr + [zeros(4,19),repmat(10000.0/(2*sqrt(u(7))),4,1)];
       
      omegasqu = ((motorcommands)/10000.0).^2;
      domegasqu = 2*repmat(motorcommands/10000.0,1,20).*dmotorcommands/10000.0;
      [xdot,dxdot] = obj.manip.dynamics(t,x,omegasqu);
      dxdot = [dxdot(:,1:13),zeros(12,7)] + dxdot(:,14:17)*domegasqu;
    end
    
    function y = output(obj,t,x,u)
      y = x;
    end
  end
  
end

