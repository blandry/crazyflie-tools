
alpha = 0.8;

vicon_object_channel = 'crazyflie_squ_ext';
imu_channel = 'crazyflie_imu';
state_estimate_channel = 'crazyflie_state_estimate'; 

dt = 0.005; %1/120;

lc = lcm.lcm.LCM.getSingleton();
imu_aggregator = lcm.lcm.MessageAggregator();
imu_aggregator.setMaxMessages(1);
lc.subscribe(imu_channel, imu_aggregator);

vicon_storage = LCMStorage(vicon_object_channel);

qd_smooth_all = [];
qd_raw_all = [];

xhat = zeros(12,1);
isinit = false;
display('publishing estimates...');
while true
  
  imu_data = imu_aggregator.getNextMessage(0);

  if ~isempty(imu_data)
    imu_msg = crazyflie_t.crazyflie_imu_t(imu_data.data); 
    imu_rpy = [imu_msg.roll -imu_msg.pitch imu_msg.yaw]'*(pi/180);
    
    vicon_data = vicon_storage.GetLatestMessage();
    vicon_msg = vicon_t.vicon_pos_t(vicon_data.data);
    
    if (vicon_msg.q(1)<=-1000)
      vicon_msg.q = xhat(1:6); % vicon lost the crazyflie
    else
      vicon_msg.q(4:6) = quat2rpy(angle2quat(vicon_msg.q(4),vicon_msg.q(5),vicon_msg.q(6),'XYZ'));
    end
    
    q_new = [vicon_msg.q(1:3);imu_rpy];
    
    if isinit
      qd_new = (q_new-xhat(1:6))/dt;
    else
      qd_new = zeros(6,1);
      isinit = true;
    end
    
    xhat(1:6) = q_new;
    xhat(7:12) = alpha*qd_new + (1-alpha)*xhat(7:12);
    
    %qd_smooth_all = [qd_smooth_all,xhat(7:12)];
    %qd_raw_all = [qd_raw_all,qd_new];
  
    estimate_msg = crazyflie_t.crazyflie_state_estimate_t();
    estimate_msg.xhat = xhat;
    lc.publish(state_estimate_channel, estimate_msg);
  end
end