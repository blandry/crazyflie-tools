classdef Crazyflie
  properties
    manip;
    
    nominal_omega_square;
    nominal_input;
    input_freq = 120;
    a = -1.208905335853438;

    vicon_frame;
    state_estimator_frame;
    
    input_frame_u;
    input_frame_omega_square_to_u;
    
    % LQR gains
    %Q = diag([100 100 300 50 50 50 1 1 1 1 1 1]);
    %Q = diag([0.001 0.001 0.001 200 200 200 0.001 0.001 0.001 10 10 10]);
    Q = 0.01*diag([30 30 200 100 100 100 30 30 30 1000 1000 1500]);
    R = eye(4);
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
      utraj = setOutputFrame(utraj,obj.input_frame_u);
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
      options.angle_flag = [0 0 0 1 1 1 0 0 0 0 0 0]';
      controller = tilqr(obj.manip,xd,obj.nominal_omega_square,obj.Q,obj.R,options);
      
      obj.state_estimator_frame.addTransform(AffineTransform(obj.state_estimator_frame,controller.getInputFrame,eye(length(xd)),-xd));
      controller = controller.inInputFrame(obj.state_estimator_frame);
      
      controller.getOutputFrame.addTransform(AffineTransform(controller.getOutputFrame,obj.input_frame_omega_square_to_u,eye(length(obj.nominal_omega_square)),repmat(38,4,1)));
      controller = controller.inOutputFrame(obj.input_frame_omega_square_to_u);
      
      runLCM(controller,[]);
    end
    
    function pd(obj)
      % Reversed engineered from the Crazyflie firmware
      u0 = 4.55;
      Z_KP = 0.0;
      ROLL_KP = 3.5*180/pi;
      PITCH_KP = 3.5*180/pi;
      YAW_KP = 0.0;
      Z_RATE_KP = 2000;
      ROLL_RATE_KP = 35*180/pi;
      PITCH_RATE_KP = 35*180/pi;
      YAW_RATE_KP = 35*180/pi;
      K = 1/10000 * [0 0 -Z_KP 0 PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 PITCH_RATE_KP YAW_RATE_KP;
                     0 0 -Z_KP ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP ROLL_RATE_KP 0 -YAW_RATE_KP;
                     0 0 -Z_KP 0 -PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 -PITCH_RATE_KP YAW_RATE_KP;
                     0 0 -Z_KP -ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP -ROLL_RATE_KP 0 -YAW_RATE_KP];
             
      controller = LinearSystem([],[],[],[],[],K);
      controller = setInputFrame(controller,obj.state_estimator_frame);
      controller = setOutputFrame(controller,LCMCoordinateFrame('crazyflie_input',InputUOffsetCoder(u0),'u'));
      runLCM(controller,[]);
    end
    
    function xtraj = simulatetilqr(obj)
      xd = [0 0 1 0 0 0 0 0 0 0 0 0]';
      controller = tilqr(obj.manip,xd,obj.nominal_omega_square,obj.Q,obj.R);
      
      noise_max = [0.1 0.1 0.1 .5 .5 1 .1 .1 .1 .5 .5 .5]';
      noise = -noise_max+2*noise_max.*rand(12,1);
      
      sys = feedback(obj.manip,controller);
      xtraj = sys.simulate([0 3],xd+noise);
      v = obj.manip.constructVisualizer();
      v.playback(xtraj,struct('slider',true));
    end
     
    function visualizeVicon(obj)
      v = obj.manip.constructVisualizer();
      v = setInputFrame(v,obj.vicon_frame);
      runLCM(v,[]);
    end
    
    function visualizeTraj(obj,xtraj)
      v = obj.manip.constructVisualizer();
      v = setInputFrame(v,getOutputFrame(xtraj));
      v.playback(xtraj,struct('slider',true));
    end
  end
  
end
