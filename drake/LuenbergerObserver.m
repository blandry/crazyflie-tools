
L = 0.4;
alpha = 0.8;

vicon_object_channel = 'crazyflie_squ_ext';
input_channel = 'crazyflie_input';
state_estimate_channel = 'crazyflie_state_estimate'; 

cf = Crazyflie();

% turns out using the Vicon specified rate gives better
% estimates than the timestamps
dt = 1/120;
delay = 0.041833;
numsteps = 5;
dtsim = delay/numsteps;
      
lc = lcm.lcm.LCM.getSingleton();

vicon_aggregator = lcm.lcm.MessageAggregator();
vicon_aggregator.setMaxMessages(1);
lc.subscribe(vicon_object_channel, vicon_aggregator);

input_storage = LCMStorage(input_channel);

finite_diff_qd = [];
estimated_qd = [];

xhat = zeros(12,1);
isinit = false;
while true
  
  vicon_data = vicon_aggregator.getNextMessage(10);

  if (length(vicon_data)>0)
    
    vicon_msg = vicon_t.vicon_pos_t(vicon_data.data);
    
    if (vicon_msg.q(1)<=-1000)
      % vicon lost the crazyflie
      vicon_msg.q = xhat(1:6);
    else
      vicon_msg.q(4:6) = quat2rpy(angle2quat(vicon_msg.q(4),vicon_msg.q(5),vicon_msg.q(6),'XYZ'));
    end
    
    if isinit
      unwrapped_rpy = unwrap([y(4:6)';vicon_msg.q(4:6)']);
      vicon_msg.q(4:6) = unwrapped_rpy(2,:);
    end
    
    if isinit
      qd = (vicon_msg.q-y(1:6))/dt;
    else
      qd = zeros(6,1);
      isinit = true;
    end
    
    y = [vicon_msg.q;qd];
    
    if (y(3)<0.45)
      xhat(1:6) = y(1:6);
      xhat(7:12) = alpha*y(7:12) + (1-alpha)*xhat(7:12);
    else
      input_data = input_storage.GetLatestMessage();
      if ~isempty(input_data);
        input_msg = crazyflie_t.crazyflie_thrust_t(input_data.data); 
        omega_square = ((1/10000)*([input_msg.thrust1 input_msg.thrust2 input_msg.thrust3 input_msg.thrust4]'+32768)-cf.a).^2;
        xhat = xhat + dt*cf.manip.dynamics(0,xhat,omega_square) + L*(y-xhat);
        % use raw vicon for position, keep estimated velocities
        xhat(1:6) = y(1:6);
        % taking the delay into account for the controller
        for i=1:numsteps
          xhat = xhat + dtsim*cf.manip.dynamics(0,xhat,omega_square);
        end
      else
        xhat = y;
      end
    end

    xhat(isnan(xhat)) = 0;
    xhat(isinf(xhat)) = 0;
    
    %finite_diff_qd = [finite_diff_qd,qd];
    %estimated_qd = [estimated_qd,xhat(7:12)];
    
    estimate_msg = crazyflie_t.crazyflie_state_estimate_t();
    estimate_msg.xhat = xhat;
    lc.publish(state_estimate_channel, estimate_msg);
  end
end


