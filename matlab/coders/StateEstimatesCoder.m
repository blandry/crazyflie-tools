classdef StateEstimatesCoder < LCMCoder

  methods
    function [xhat,t] = decode(obj,data)
      msg = crazyflie_t.crazyflie_state_estimate_t(data);
      xhat = msg.xhat;
      t = msg.t;
    end
    
    function msg = encode(obj,t,xhat)
      msg = crazyflie_t.crazyflie_state_estimate_t();
      msg.xhat = xhat;
      msg.t = t;
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