
alpha = 0.8;

vicon_object_channel = 'crazyflie_squ_ext';
imu_channel = 'crazyflie_imu';

state_estimate_channel = 'crazyflie_state_estimate'; 

lc = lcm.lcm.LCM.getSingleton();
imu_aggregator = lcm.lcm.MessageAggregator();
imu_aggregator.setMaxMessages(1);
lc.subscribe(imu_channel, imu_aggregator);

vicon_storage = LCMStorage(vicon_object_channel);

raw = [];
estimates = [];
vicon_angle_raw = zeros(3,1);

xhat = zeros(12,1);
xyz_isinit = false;
display('publishing estimates...');
while true
  
  imu_data = imu_aggregator.getNextMessage(0);

  if ~isempty(imu_data)
      
    imu_msg = crazyflie_t.crazyflie_imu_t(imu_data.data); 
    rpy = [imu_msg.roll imu_msg.pitch imu_msg.yaw]'*(pi/180);
    drpy = [imu_msg.rolld imu_msg.pitchd imu_msg.yawd]'*(pi/180);
    
%     vicon_data = vicon_storage.GetLatestMessage();
%     vicon_msg = vicon_t.vicon_pos_t(vicon_data.data);
%     
%     if (vicon_msg.q(1)<=-1000)
%       new_xyz = xhat(1:3); % vicon lost the crazyflie
%     else
%       new_xyz = vicon_msg.q(1:3);
%     end
%     
%     if xyz_isinit
%       if (vicon_msg.timestamp>old_xyz_t)
%         dxyz = 10000*(new_xyz-old_xyz)/(vicon_msg.timestamp-old_xyz_t);
%         dvicon_angle_raw = 10000*(quat2rpy(angle2quat(vicon_msg.q(4),vicon_msg.q(5),vicon_msg.q(6),'XYZ'))-vicon_angle_raw)/(vicon_msg.timestamp-old_xyz_t);
%       end
%     else
%       dxyz = [0 0 0]';
%       xyz_isinit = true;
%       dvicon_angle_raw = zeros(3,1);
%     end
%     old_xyz = new_xyz;
%     old_xyz_t = vicon_msg.timestamp;
%     vicon_angle_raw = quat2rpy(angle2quat(vicon_msg.q(4),vicon_msg.q(5),vicon_msg.q(6),'XYZ'));
%     
%     xhat(1:6) = [new_xyz;rpy];
%     xhat(7:12) = alpha*[dxyz;drpy] + (1-alpha)*xhat(7:12);
%     
% %     raw = [raw,[new_xyz;vicon_angle_raw;dxyz;dvicon_angle_raw]];
% %     estimates = [estimates,xhat];
    
    xhat = [0;0;0;rpy;alpha*[0;0;0;drpy] + (1-alpha)*xhat(7:12)];

    estimate_msg = crazyflie_t.crazyflie_state_estimate_t();
    estimate_msg.xhat = xhat;
    lc.publish(state_estimate_channel, estimate_msg);
  end
end