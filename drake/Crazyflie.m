classdef Crazyflie
  properties
    manip;
    
    nominal_input;
    
    % only used with open loop trajectories
    input_freq = 200;

    % only used with LQR
    Q = diag([25 25 25 1 1 5 .001 .001 .001 2.5 2.5 5.0]);
    R = eye(4);
    
    tvQ = diag([25 25 25 1 1 5 .001 .001 .001 2.5 2.5 5.0]);
    tvR = eye(4);
  end
  
  methods
    
    function obj = Crazyflie()
      options.floating = true;
      obj.manip = RigidBodyManipulator('crazyflie2.urdf',options);
      obj.nominal_input = .25*norm(getMass(obj.manip)*obj.manip.gravity)./ ...
          [obj.manip.force{1}.scale_factor_thrust obj.manip.force{2}.scale_factor_thrust ...
          obj.manip.force{3}.scale_factor_thrust obj.manip.force{4}.scale_factor_thrust]';
    end
    
    function run(obj, utraj, input_type, tspan)
      if (nargin<3)
        input_type = '32bits';
      end
      input_frame = LCMCoordinateFrame('crazyflie_input',InputCoder(input_type),'u');
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
    
    function tilqr(obj, xd)
      if (nargin<2)
        xd = zeros(12,1);
      end
       
      options.angle_flag = [0 0 0 1 1 1 0 0 0 0 0 0]';
      controller = tilqr(obj.manip,xd,obj.nominal_input,obj.Q,obj.R,options);
      
      state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatesCoder,'x');
      state_estimator_frame.addTransform(AffineTransform(state_estimator_frame,controller.getInputFrame,eye(length(xd)),-xd));
      controller = controller.inInputFrame(state_estimator_frame);
      
      input_frame = LCMCoordinateFrame('crazyflie_input',InputCoder('omegasqu'),'u');
      controller.getOutputFrame.addTransform(AffineTransform(controller.getOutputFrame,input_frame,eye(length(obj.nominal_input)),obj.nominal_input-15));
      controller = controller.inOutputFrame(input_frame);
      
      runLCM(controller,[]);
    end
    
    function controller = gettvlqr(obj, xtraj, utraj)
      options.angle_flag = [0 0 0 1 1 1 0 0 0 0 0 0]';
      
      % use the TILQR infinite cost to go as final cost on TVLQR (this
      % assumes that your final position is a fixed point
      tf = xtraj.tspan(2);
      [~,V] = tilqr(obj.manip,xtraj.eval(tf),utraj.eval(tf),obj.Q,obj.R,options);
      Qf = V.S;
      
      controller = tvlqr(obj.manip,xtraj,utraj,obj.tvQ,obj.tvR,Qf,options);
    end
    
    function runtvlqr(obj, controller, xtraj, utraj)
      state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatesCoder,'x');
      state_estimator_frame.addTransform(AffineTransform(state_estimator_frame,controller.getInputFrame,eye(12),-xtraj));
      controller = controller.inInputFrame(state_estimator_frame);
      
      input_frame = LCMCoordinateFrame('crazyflie_input',InputCoder('omegasqu'),'u');
      controller.getOutputFrame.addTransform(AffineTransform(controller.getOutputFrame,input_frame,eye(4),utraj-ConstantTrajectory(repmat(14.5,4,1))));
      controller = controller.inOutputFrame(input_frame);

      runLCM(controller,[]);
    end
      
    function pd(obj, xd)
      if (nargin<2)
        xd = zeros(12,1);
      end
      
%       input_type = '32bits';
%       u0 = zeros(4,1);
%       ROLL_KP = 1.2*3.5*180/pi;
%       PITCH_KP = 1.2*3.5*180/pi;
%       YAW_KP = 0.0;
%       ROLL_RATE_KP = .8*70*180/pi;
%       PITCH_RATE_KP = .8*70*180/pi; 
%       YAW_RATE_KP = .8*50*180/pi;

      input_type = 'omegasqu';
      u0 = zeros(4,1);
      ROLL_KP = 1.2*.7;
      PITCH_KP = 1.2*.7;
      YAW_KP = 0;
      ROLL_RATE_KP = .8*.8;
      PITCH_RATE_KP = .8*.8;
      YAW_RATE_KP = .8*.6;
      K = [0 0 0 0 PITCH_KP YAW_KP 0 0 0 0 PITCH_RATE_KP YAW_RATE_KP;
           0 0 0 ROLL_KP 0 -YAW_KP 0 0 0 ROLL_RATE_KP 0 -YAW_RATE_KP;
           0 0 0 0 -PITCH_KP YAW_KP 0 0 0 0 -PITCH_RATE_KP YAW_RATE_KP;
           0 0 0 -ROLL_KP 0 -YAW_KP 0 0 0 -ROLL_RATE_KP 0 -YAW_RATE_KP];
             
      controller = LinearSystem([],[],[],[],[],K);
      
      state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatesCoder,'x');
      state_estimator_frame.addTransform(AffineTransform(state_estimator_frame,controller.getInputFrame,eye(length(xd)),-xd));
      controller = controller.inInputFrame(state_estimator_frame);
      
      input_frame = LCMCoordinateFrame('crazyflie_input',InputCoder(input_type),'u');
      controller.getOutputFrame.addTransform(AffineTransform(controller.getOutputFrame,input_frame,eye(length(u0)),u0));
      controller = controller.inOutputFrame(input_frame);
      
      runLCM(controller,[]);
    end
    
    function xtraj = simulatetilqr(obj)
      xd = [0 0 1 0 0 0 0 0 0 0 0 0]';
      options.angle_flag = [0 0 0 1 1 1 0 0 0 0 0 0]';
      controller = tilqr(obj.manip,xd,obj.nominal_input,obj.Q,obj.R,options);
      
      noise_max = [0.1 0.1 0.1 .5 .5 1 .1 .1 .1 .5 .5 .5]';
      noise = -noise_max+2*noise_max.*rand(12,1);
      
      sys = feedback(obj.manip,controller);
      xtraj = sys.simulate([0 5],xd+noise);
      
      v = obj.manip.constructVisualizer();
      v.playback(xtraj,struct('slider',true));
    end
    
    function xtraj = simulatetvlqr(obj, xtraj, utraj)
      options.angle_flag = [0 0 0 1 1 1 0 0 0 0 0 0]';
      controller = tvlqr(obj.manip,xtraj,utraj,obj.tvQ,obj.tvR,obj.tvQf,options);
            
      sys = feedback(obj.manip,controller);
      systraj = sys.simulate([0 5],xtraj.eval(0));
      
      v = obj.manip.constructVisualizer();
      v.playback(systraj,struct('slider',true));
    end
    
    function visualize(obj)
      v = obj.manip.constructVisualizer();
      state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatesCoder,'x');
      state_estimator_frame.addTransform(AffineTransform(state_estimator_frame,v.getInputFrame,[eye(6),zeros(6)],zeros(6,1)));
      v = v.inInputFrame(state_estimator_frame);
      runLCM(v,[]);
    end

  end
  
end
