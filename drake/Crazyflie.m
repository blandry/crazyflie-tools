classdef Crazyflie
  properties
    manip;
    a = -1.499999942623626e+04;
    sensor_frame;
    state_estimator_frame;
    pos_estimator_frame;
    input_frame;
    input_frame_from_drake;
    nominal_omega_square;
    nominal_input;
    input_freq = 200;
  end
  
  methods
    
    function obj = Crazyflie()
      options.floating = true;
      obj.manip = RigidBodyManipulator('Crazyflie.URDF',options);
      obj.sensor_frame = LCMCoordinateFrame('crazyflie_squ_ext',ViconLCMCoder,'x');
      obj.state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatorLCMCoder,'x');
      obj.pos_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',PosEstimatorLCMCoder,'x');
      obj.input_frame = LCMCoordinateFrame('crazyflie_input',CFInputLCMCoder,'u');
      obj.input_frame_from_drake = LCMCoordinateFrame('crazyflie_input',CFInputFromdDrakeCoder,'u');
      
      % the model for thrust is
      % omega = u - a
      % Thrust = kf*omega^2
      % Drake's model input is omega^2
      obj.nominal_omega_square = norm(getMass(obj.manip)*obj.manip.gravity)/(obj.manip.force{1}.scale_factor_moment*4);
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
      R = 10*eye(4);
      
      ltisys = tilqr(obj.manip,xd,obj.nominal_omega_square,Q,R);
      ltisys = setInputFrame(ltisys,obj.state_estimator_frame);
      ltisys = steOutputFrame(ltisys,obj.input_frame_from_drake);
      runLCM(ltisys,[]);
    end
    
    function runtvlqr(obj, xtraj, utraj)
      error('Not implemented yet...');
    end
  end
  
end
