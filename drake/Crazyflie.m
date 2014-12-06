classdef Crazyflie
  properties
    manip;
    sensor_frame;
    state_estimator_frame;
    pos_estimator_frame;
    input_frame;
    nominal_thrust;
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
 
      obj.nominal_thrust = norm(getMass(obj.manip)*obj.manip.gravity)/(obj.manip.force{1}.scale_factor_moment*4);
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
      ltisys = tilqr(obj.manip,xd,obj.nominal_thrust, Q,R);
      ltisys = setInputFrame(ltisys,obj.state_estimator_frame);
      ltisys = steOutputFrame(ltisys,obj.input_frame);
      runLCM(ltisys,[]);
    end
    
    function runtvlqr(obj, xtraj, utraj)
      display('no');
    end
  end
  
end
