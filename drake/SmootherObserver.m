
alpha = 0.8;
xhat = zeros(12,1);

vicon_object_channel = 'crazyflie_squ_ext';
state_estimate_channel = 'crazyflie_state_estimate'; 
dt = 1/120;

lc = lcm.lcm.LCM.getSingleton();
vicon_aggregator = lcm.lcm.MessageAggregator();
vicon_aggregator.setMaxMessages(1);
lc.subscribe(vicon_object_channel, vicon_aggregator);

% qd_smooth_all = [];
% qd_raw_all = [];

q_measured = zeros(6,1);
qd_measured = zeros(6,1);
isinit = false;
while true
  
  vicon_data = vicon_aggregator.getNextMessage(0);

  if ~isempty(vicon_data)
    vicon_msg = vicon_t.vicon_pos_t(vicon_data.data);
    if (vicon_msg.q(1)<=-1000)
      vicon_msg.q = xhat(1:6); % vicon lost the crazyflie
    end
    vicon_msg.q(4:6) = quat2rpy(angle2quat(vicon_msg.q(4),vicon_msg.q(5),vicon_msg.q(6),'XYZ'));
    
    if isinit
      qd_new = (vicon_msg.q-q_measured)/dt;
    else
      qd_new = zeros(6,1);
      isinit = true;
    end

    % qd_smooth_all = [qd_smooth_all,alpha*qd_new + (1-alpha)*qd_measured];
    % qd_raw_all = [qd_raw_all,qd_new];
    
    qd_measured = alpha*qd_new + (1-alpha)*qd_measured;
    q_measured = vicon_msg.q;
    y = [q_measured;qd_measured];
  
    xhat = y;
    estimate_msg = crazyflie_t.crazyflie_state_estimate_t();
    estimate_msg.xhat = xhat;
    lc.publish(state_estimate_channel, estimate_msg);
  end
end