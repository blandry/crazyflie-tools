classdef StateEstimatesCoder < LCMCoder

  methods
    function [xhat,t] = decode(obj,data)
      msg = crazyflie_t.crazyflie_state_estimate_t(data);
      R = rpy2rotmat(msg.xhat(4:6));
      xhat = [msg.xhat(1:9);angularvel2rpydot(msg.xhat(4:6),R*msg.xhat(10:12))];
      t = msg.timestamp;
    end
    
    function msg = encode(obj,t,xhat)
      msg = crazyflie_t.crazyflie_state_estimate_t();
      msg.xhat = xhat;
      msg.timestamp = t;
    end
    
    function d = dim(obj)
      d = 12;
    end
    
    function str = timestampName(obj)
      str = 'timestamp';
    end
    
    function names = coordinateNames(obj)
      names = {'x','y','z','roll','pitch','yaw','xdot','ydot','zdot','rolldot','pitchdot','yawdot'};
    end
  end

end