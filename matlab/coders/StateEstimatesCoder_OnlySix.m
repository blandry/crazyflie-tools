classdef StateEstimatesCoder_OnlySix < LCMCoder

  methods
    function [xhat,t] = decode(obj,data)
      msg = crazyflie_t.crazyflie_state_estimate_t(data);
      xhat = msg.xhat(1:6);
      t = msg.t;
    end
    
    function msg = encode(obj,t,xhat)
      msg = crazyflie_t.crazyflie_state_estimate_t();
      msg.xhat = xhat;
      msg.t = t;
    end
    
    function d = dim(obj)
      d = 6;
    end
    
    function str = timestampName(obj)
      str = 'timestamp';
    end
    
    function names = coordinateNames(obj)
      names = {'x','y','z','roll','pitch','yaw'};
    end
  end

end