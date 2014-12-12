classdef Crazyflie
  properties
    manip;
    
    nominal_omega_square;
    nominal_input;
    input_freq = 240;
    a = -1.208905335853438;

    vicon_frame;
    state_estimator_frame;
    
    input_frame_u;
    input_frame_omega_square_to_u;
  end
  
  methods
    
    function obj = Crazyflie()
      options.floating = true;
      obj.manip = RigidBodyManipulator('crazyflie.urdf',options);

      obj.nominal_omega_square = repmat(norm(getMass(obj.manip)*obj.manip.gravity)/(obj.manip.force{1}.scale_factor_thrust*4),4,1);
      obj.nominal_input = sqrt(obj.nominal_omega_square)+obj.a;
            
      obj.vicon_frame = LCMCoordinateFrame('crazyflie_squ_ext',ViconCoder,'x');
      obj.state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatorCoder,'x');
      
      obj.input_frame_u = LCMCoordinateFrame('crazyflie_input',InputUCoder,'u');
      obj.input_frame_omega_square_to_u = LCMCoordinateFrame('crazyflie_input',InputOmegaSquareToUCoder(obj.a),'u');
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
    
    function tilqr(obj,xd)
      Q = 1000*eye(12);
      R = .1*eye(4);
      controller = tilqr(obj.manip,xd,obj.nominal_omega_square,Q,R);
      controller = setInputFrame(controller,obj.state_estimator_frame);
      controller = setOutputFrame(controller,obj.input_frame_omega_square_to_u);
      runLCM(controller,[]);
    end
    
    function pd(obj)
      % Reversed engineered from the Crazyflie firmware
      Z_KP = 0.0;
      ROLL_KP = 3.5;
      PITCH_KP = 3.5;
      YAW_KP = 0.0;
      Z_RATE_KP = 1400;
      ROLL_RATE_KP = 35;
      PITCH_RATE_KP = 35;
      YAW_RATE_KP = 30;
      K = 1/10000 * [0 0 -Z_KP 0 PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 PITCH_RATE_KP YAW_RATE_KP;
                     0 0 -Z_KP ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP ROLL_RATE_KP 0 -YAW_RATE_KP;
                     0 0 -Z_KP 0 -PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 -PITCH_RATE_KP YAW_RATE_KP;
                     0 0 -Z_KP -ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP -ROLL_RATE_KP 0 -YAW_RATE_KP];
             
      controller = LinearSystem([],[],[],[],[],K);
      controller = setInputFrame(controller,obj.state_estimator_frame);
      controller = setOutputFrame(controller,LCMCoordinateFrame('crazyflie_input',InputUOffsetCoder(5),'u'));
      runLCM(controller,[]);
    end
    
    function simulatetilqr(obj,xd,x0,tf)
      if (nargin<3)
        x0 = zeros(12,1);
      end
      if (nargin<4)
        tf = 1;
      end
      Q = 1000*eye(12);
      R = .1*eye(4);
      controller = tilqr(obj.manip,xd,obj.nominal_omega_square,Q,R);
      
      sys = feedback(obj.manip,controller);
      xtraj = sys.simulate([0 tf],x0);
      v = obj.manip.constructVisualizer();
      v.playback(xtraj,struct('slider',true));
    end
     
    function visualizeVicon(obj)
      v = obj.manip.constructVisualizer();
      v = setInputFrame(v,obj.vicon_frame);
      runLCM(v,[]);
    end
  end
  
end
