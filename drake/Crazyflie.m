classdef Crazyflie
  properties
    manip;
    
    nominal_input;
    input_freq = 120;
    
    %Q = diag([.3 .3 10 1 1 1 .3 .3 .3 10 10 15]);
    %Q = diag([.3 .3 .001 1 1 1 .3 .3 .001 10 10 15]);
    %Q = diag([1 1 100 .075 .075 .075 .3 .3 .3 10 10 25]);
    %Q = diag([5 5 100 300 300 300 1 1 1 .1 .1 .1]);
    Q = diag([1 1 1 10 10 10 1 1 1 10 10 10]);
    R = eye(4);
  end
  
  methods
    
    function obj = Crazyflie()
      options.floating = true;
      obj.manip = RigidBodyManipulator('crazyflie.urdf',options);
      obj.nominal_input = .25*norm(getMass(obj.manip)*obj.manip.gravity)./ ...
          [obj.manip.force{1}.scale_factor_thrust obj.manip.force{2}.scale_factor_thrust ...
          obj.manip.force{3}.scale_factor_thrust obj.manip.force{4}.scale_factor_thrust]';
    end
    
    function run(obj, utraj, input_type, tspan)
      if (nargin<3)
        input_frame = LCMCoordinateFrame('crazyflie_input',InputCoder('32bits'),'u');
      else
        input_frame = LCMCoordinateFrame('crazyflie_input',InputCoder(input_type),'u');
      end
      utraj = setOutputFrame(utraj,input_frame);
      if (nargin<4)
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
    
    function xtraj = simulatetilqr(obj)
      xd = [0 0 1 0 0 0 0 0 0 0 0 0]';
      controller = tilqr(obj.manip,xd,obj.nominal_input,obj.Q,obj.R,options);
      
      noise_max = [0.1 0.1 0.1 .5 .5 1 .1 .1 .1 .5 .5 .5]';
      noise = -noise_max+2*noise_max.*rand(12,1);
      
      sys = feedback(obj.manip,controller);
      xtraj = sys.simulate([0 5],xd+noise);
      
      v = obj.manip.constructVisualizer();
      v.playback(xtraj,struct('slider',true));
    end
    
    function tilqr(obj, xd)      
      options.angle_flag = [0 0 0 1 1 1 0 0 0 0 0 0]';
      controller = tilqr(obj.manip,xd,obj.nominal_input,obj.Q,obj.R,options);
      
      state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatesCoder,'x');
      state_estimator_frame.addTransform(AffineTransform(state_estimator_frame,controller.getInputFrame,eye(length(xd)),-xd));
      controller = controller.inInputFrame(state_estimator_frame);
      
      input_frame = LCMCoordinateFrame('crazyflie_input',InputCoder('omegasqu'),'u');
      controller.getOutputFrame.addTransform(AffineTransform(controller.getOutputFrame,input_frame,eye(length(obj.nominal_input)),obj.nominal_input));
      controller = controller.inOutputFrame(input_frame);
      
      runLCM(controller,[]);
    end
    
    function pd(obj)
      % Reversed engineered from the Crazyflie firmware
      
      u0 = [43000 43000 43000 43000]'+10000;
      
      Z_KP = 0.0;
      ROLL_KP = 3.5*180/pi;
      PITCH_KP = 3.5*180/pi;
      YAW_KP = 0.0;
      
      Z_RATE_KP = 0.0;
      ROLL_RATE_KP = .5*70*180/pi;
      PITCH_RATE_KP = .5*70*180/pi; 
      YAW_RATE_KP = .5*50*180/pi;
      
      K = [0 0 -Z_KP 0 PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 PITCH_RATE_KP YAW_RATE_KP;
           0 0 -Z_KP ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP ROLL_RATE_KP 0 -YAW_RATE_KP;
           0 0 -Z_KP 0 -PITCH_KP YAW_KP 0 0 -Z_RATE_KP 0 -PITCH_RATE_KP YAW_RATE_KP;
           0 0 -Z_KP -ROLL_KP 0 -YAW_KP 0 0 -Z_RATE_KP -ROLL_RATE_KP 0 -YAW_RATE_KP];
             
      controller = LinearSystem([],[],[],[],[],K);
      
      xd = zeros(12,1);
      state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatesCoder,'x');
      state_estimator_frame.addTransform(AffineTransform(state_estimator_frame,controller.getInputFrame,eye(length(xd)),-xd));
      controller = controller.inInputFrame(state_estimator_frame);
      
      input_frame = LCMCoordinateFrame('crazyflie_input',InputCoder('32bits'),'u');
      controller.getOutputFrame.addTransform(AffineTransform(controller.getOutputFrame,input_frame,eye(length(u0)),u0));
      controller = controller.inOutputFrame(input_frame);
      
      runLCM(controller,[]);
    end

  end
  
end
