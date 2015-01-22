
alpha = 0.8;

vicon_object_channel = 'crazyflie_squ_ext';
state_estimate_channel = 'crazyflie_state_estimate'; 
dt = 1/120;

lc = lcm.lcm.LCM.getSingleton();
vicon_aggregator = lcm.lcm.MessageAggregator();
vicon_aggregator.setMaxMessages(1);
lc.subscribe(vicon_object_channel, vicon_aggregator);

qd_smooth_all = [];
qd_raw_all = [];

xhat = zeros(12,1);
isinit = false;
display('publishing estimates...');
while true
  
  vicon_data = vicon_aggregator.getNextMessage(0);

  if ~isempty(vicon_data)
    vicon_msg = vicon_t.vicon_pos_t(vicon_data.data);
    
    if (vicon_msg.q(1)<=-1000)
      vicon_msg.q = xhat(1:6); % vicon lost the crazyflie
    else
      vicon_msg.q(4:6) = quat2rpy(angle2quat(vicon_msg.q(4),vicon_msg.q(5),vicon_msg.q(6),'XYZ'));
    end
    
    if isinit
      qd_new = (vicon_msg.q-xhat(1:6))/dt;
    else
      qd_new = zeros(6,1);
      isinit = true;
    end
    
    xhat(1:6) = vicon_msg.q;
    xhat(7:12) = alpha*qd_new + (1-alpha)*xhat(7:12);
    
    %qd_smooth_all = [qd_smooth_all,xhat(7:12)];
    %qd_raw_all = [qd_raw_all,qd_new];
  
    estimate_msg = crazyflie_t.crazyflie_state_estimate_t();
    estimate_msg.xhat = xhat;
    lc.publish(state_estimate_channel, estimate_msg);
  end
end