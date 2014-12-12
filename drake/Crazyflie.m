classdef Crazyflie
  properties
    manip;
    
    nominal_omega_square;
    nominal_input;
    input_freq = 120;
    a = -1.208905335853438;

    vicon_frame;
    state_estimator_frame;
    
    input_frame_u; % getting u, broadcasting 10000*u-32768
    input_frame_u_offset; % getting u, broadcasting 10000*(u+offset)-32768
    input_frame_omega_square_to_u; % getting omega^2, broadcasting 10000*u-32768
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
      obj.input_frame_u_offset = LCMCoordinateFrame('crazyflie_input',InputUOffsetCoder(obj.nominal_input),'u');
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
      controller = pdcontroller();
      controller = setInputFrame(controller,obj.state_estimator_frame);
      controller = setOutputFrame(controller,obj.input_frame_u_offset);
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
