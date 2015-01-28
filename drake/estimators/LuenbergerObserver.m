
L = .4;
alpha = 0.8;

dt = 1/120;

delay = 0.041833;
numsteps = 5;
dtsim = delay/numsteps;

qd_max = [2 2 2 100 100 100]';
z_min = 0.45;

cf = Crazyflie();

vicon_object_channel = 'crazyflie_squ_ext';
input_channel = 'crazyflie_input';
state_estimate_channel = 'crazyflie_state_estimate'; 
      
lc = lcm.lcm.LCM.getSingleton();

vicon_aggregator = lcm.lcm.MessageAggregator();
vicon_aggregator.setMaxMessages(1);
lc.subscribe(vicon_object_channel, vicon_aggregator);

input_storage = LCMStorage(input_channel);

raw_pos = [];
estimates = [];

isinit = false;
display('publishing estimates...');
while true
  vicon_data = vicon_aggregator.getNextMessage(0);
  if ~isempty(vicon_data)
    vicon_msg = vicon_t.vicon_pos_t(vicon_data.data);
    if (vicon_msg.q(1)>-1000)
      vicon_msg.q(4:6) = quat2rpy(angle2quat(vicon_msg.q(4),vicon_msg.q(5),vicon_msg.q(6),'XYZ'));
      if isinit
        unwrapped_rpy = unwrap([y(4:6)';vicon_msg.q(4:6)']);
        vicon_msg.q(4:6) = unwrapped_rpy(2,:);
        qd = (vicon_msg.q-y(1:6))/dt; 
        y = [vicon_msg.q;qd];
        if ~any((abs(qd)-qd_max)>0)
          if (y(3)>z_min)
            input_data = input_storage.GetLatestMessage();
            if ~isempty(input_data)
              input_msg = crazyflie_t.crazyflie_thrust_t(input_data.data);
              if strcmp(input_msg.type,'omegasqu')
                xhatmp = xhat + dt*cf.manip.dynamics(0,xhat,input_msg.input) + L*(y-xhat);
                xhatmp(1:6) = alpha*y(1:6)+(1-alpha)*xhat(1:6);
                % delay compensation
                %for i=1:numsteps
                %  xhatmp = xhatmp + dtsim*cf.manip.dynamics(0,xhatmp,input_msg.input);
                %end
                if (any(isnan(xhatmp))||any(isinf(xhatmp))) 
                  xhat = alpha*y + (1-alpha)*xhat; 
                else
                  xhat = xhatmp;
                end
              else
                xhat = alpha*y + (1-alpha)*xhat;
              end
            else
              xhat = alpha*y + (1-alpha)*xhat; 
            end
          else
            xhat = alpha*y + (1-alpha)*xhat; 
          end
        end
      else
        y = [vicon_msg.q;zeros(6,1)];
        xhat = y;
        isinit = true;
      end
      estimate_msg = crazyflie_t.crazyflie_state_estimate_t();
      estimate_msg.xhat = xhat;
      lc.publish(state_estimate_channel, estimate_msg);
      %raw_pos = [raw_pos,vicon_msg.q];
      %estimates = [estimates,xhat];
    end
  end
end