classdef CrazyflieModel < DrakeSystem
  
  properties
    manip;
    pdK;
    nominal_thrust;
    nominal_input;
    
    A_OFFSET = 3300.0;
    B_OFFSET = 2.8;
    
    ROLL_KP = 10*3.5*180/pi;
    PITCH_KP = 10*3.5*180/pi;
    YAW_KP = 10*3.5*180/pi;
    ROLL_RATE_KP = 70*180/pi;
    PITCH_RATE_KP = 70*180/pi; 
    YAW_RATE_KP = 100*180/pi;
  end
  
  methods
    function obj = CrazyflieModel()
      obj = obj@DrakeSystem(12,0,7,12,false,true);
      options.floating = true;
      obj.manip = RigidBodyManipulator('crazyflie.urdf',options);
      obj.nominal_thrust = .25*norm(getMass(obj.manip)*obj.manip.gravity)/obj.manip.force{1}.scale_factor_thrust;
      obj.nominal_input = sqrt(10000*((obj.nominal_thrust+obj.B_OFFSET)^2/10000-obj.A_OFFSET));
      obj.pdK = [0 obj.PITCH_KP obj.YAW_KP 0 obj.PITCH_RATE_KP obj.YAW_RATE_KP;
                 obj.ROLL_KP 0 -obj.YAW_KP obj.ROLL_RATE_KP 0 -obj.YAW_RATE_KP;
                 0 -obj.PITCH_KP obj.YAW_KP 0 -obj.PITCH_RATE_KP obj.YAW_RATE_KP;
                 -obj.ROLL_KP 0 -obj.YAW_KP -obj.ROLL_RATE_KP 0 -obj.YAW_RATE_KP];
    end
    
    function x0 = getInitialState(obj)
      x0 = zeros(12,1);
    end
    
    function xdot = dynamics(obj,t,x,u)
      % states: xyz, rpy, dxyz, drpy
      % inputs: rpydesired,omegadesired,thrust
      
      R = rpy2rotmat(x(4:6));
      pqr = rpydot2angularvel(x(4:6),x(10:12));
      pqr = R'*pqr;

      err = [x(4:6);pqr]-u(1:6);
      %motorcommands = obj.pdK*err + sqrt(max(0.0,u(7)-obj.B_OFFSET))*10000.0+obj.A_OFFSET;
      motorcommands = obj.pdK*err + sqrt(u(7))*10000.0;
      
      omegasqu = ((motorcommands)/10000.0).^2;
      xdot = obj.manip.dynamics(t,x,omegasqu);
    end
    
    function y = output(obj,t,x,u)
      % outputs: xyz, rpy, dxyz, drpy
      y = x;
    end
  end
  
end

