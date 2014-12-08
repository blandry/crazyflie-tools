function runLuenbergerObserver()

L = 0.2;

vicon_object_channel = 'crazyflie_squ_ext';
input_channel = 'crazyflie_input';
state_estimate_channel = 'crazyflie_state_estimate'; 

xhat = zeros(12,1);

options.floating = true;
p = RigidBodyManipulator('Crazyflie.URDF',options);

% turns out using the Vicon specified rate gives better
% estimates than the timestamps
dt = 1/120;

lc = lcm.lcm.LCM.getSingleton();

vicon_aggregator = lcm.lcm.MessageAggregator();
vicon_aggregator.setMaxMessages(1);
lc.subscribe(vicon_object_channel, vicon_aggregator);

input_aggregator = lcm.lcm.MessageAggregator();
input_aggregator.setMaxMessages(1);
lc.subscribe(input_channel, input_aggregator);

q_measured = zeros(6,1);
isinit = false;
while true
  
  input_data = input_aggregator.getNextMessage(0);
  vicon_data = vicon_aggregator.getNextMessage(0);

  if (length(vicon_data)>0)
    
    vicon_msg = vicon_t.vicon_pos_t(vicon_data.data);
    if (vicon_msg.q(1)<=-1000000)
      % vicon lost the crazyflie
      vicon_msg.q = xhat(1:6);
    end
    vicon_msg.q(4:6) = quat2rpy(angle2quat(vicon_msg.q(4),vicon_msg.q(5),vicon_msg.q(6),'XYZ'));
    if isinit
      unwrapped_rpy = unwrap([q_measured(4:6)';vicon_msg.q(4:6)']);
      vicon_msg.q(4:6) = unwrapped_rpy(2,:);
    end
    
    if isinit
      qd_measured = (vicon_msg.q-q_measured)/dt;
    else
      qd_measured = zeros(6,1);
      isinit = true;
    end
    q_measured = vicon_msg.q;
    y = [q_measured;qd_measured];

    if (length(input_data)>0)
      input_msg = crazyflie_t.crazyflie_thrust_t(input_data.data); 
      a = -1.499999942623626e+04;
      u = [(input_msg.thrust1+32768-a)^2 (input_msg.thrust2+32768-a)^2 (input_msg.thrust3+32768-a)^2 (input_msg.thrust4+32768-a)^2]';
    else
      u = zeros(4,1);
    end

    xhat = xhat + dt*p.dynamics(0,xhat,u) + L*(y-xhat);
    
    % use raw vicon for position, keep estimated velocities
    xhat(1:6) = y(1:6);
    
    delay = 0.041833;
    xhat = xhat + delay*p.dynamics(0,xhat,u);

    % safety net in case the estimator goes crazy
    xhat(isnan(xhat)) = 0;
    
    estimate_msg = crazyflie_t.crazyflie_state_estimate_t();
    estimate_msg.xhat = xhat;
    lc.publish(state_estimate_channel, estimate_msg);
  end
end

end

