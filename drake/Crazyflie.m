classdef Crazyflie
  properties
    sensor_frame;
    state_estimator_frame;
    pos_estimator_frame;
    input_frame;
    input_frame_from_drake;
    
    manip;
    nominal_omega_square;
    nominal_input;
    
    input_freq = 200;
    a = -1.499999942623626e+04;
  end
  
  methods
    
    function obj = Crazyflie()
      options.floating = true;
      obj.manip = RigidBodyManipulator('Crazyflie.URDF',options);
      
      obj.sensor_frame = LCMCoordinateFrame('crazyflie_squ_ext',ViconLCMCoder,'x');
      obj.state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatorLCMCoder,'x');
      obj.pos_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',PosEstimatorLCMCoder,'x');
      obj.input_frame = LCMCoordinateFrame('crazyflie_input',CFInputLCMCoder,'u');
      obj.input_frame_from_drake = LCMCoordinateFrame('crazyflie_input',CFInputFromDrakeLCMCoder,'u');
      
      % the model for thrust is
      % omega = u - a
      % Thrust = kf*omega^2
      % Drake's model input is omega^2
      obj.nominal_omega_square = repmat(norm(getMass(obj.manip)*obj.manip.gravity)/(obj.manip.force{1}.scale_factor_thrust*4),4,1);
      obj.nominal_input = sqrt(obj.nominal_omega_square)+obj.a;
    end
    
    function run(obj, utraj, tspan)
      utraj = setOutputFrame(utraj,obj.input_frame);
      if (nargin<3)
        options.tspan = utraj.tspan;
        if (options.tspan(1)<0)
          options.tspan(1) = 0;
        end
      else
        options.tspan = tspan;
      end
      options.input_sample_time = 1/obj.input_freq;
      runLCM(utraj,[],options);
    end
    
    function visualizeEstimator(obj)
      v = obj.manip.constructVisualizer();
      v = setInputFrame(v,obj.pos_estimator_frame);
      runLCM(v,[]);
    end
    
    function stabilize(obj,xd)
      Q = eye(12);
      R = 1E-15*eye(4);
      ltisys = tilqr(obj.manip,xd,obj.nominal_omega_square,Q,R);
      ltisys = setInputFrame(ltisys,obj.state_estimator_frame);
      ltisys = setOutputFrame(ltisys,obj.input_frame_from_drake);
      runLCM(ltisys,[]);
    end
    
    function simulateStabilize(obj,x0,xd,tf)
      if (nargin<4)
        tf = 2;
      end
      Q = 10000*eye(12);
      R = (1/obj.nominal_omega_square(1))*eye(4);
      ltisys = tilqr(obj.manip,xd,obj.nominal_omega_square,Q,R);
      sys = feedback(obj.manip,ltisys);
      xtraj = sys.simulate([0 tf],x0);
      v = obj.manip.constructVisualizer();
      v.playback(xtraj,struct('slider',true));
    end
    
    function runtvlqr(obj, xtraj, utraj)
      error('Not implemented yet...');
    end
  end
  
end
