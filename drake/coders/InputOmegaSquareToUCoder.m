classdef InputOmegaSquareToUCoder < LCMCoder
  
  properties
    a;
  end
  
  methods
    function obj = InputOmegaSquareToUCoder(a)
      obj = obj@LCMCoder();
      obj.a = a;
    end
    function [omega_square,t] = decode(obj,data)
      msg = crazyflie_t.crazyflie_thrust_t(data);
      omega_square = ((1/10000)*([msg.thrust1 msg.thrust2 msg.thrust3 msg.thrust4]'+32768)-obj.a).^2;
      t = msg.timestamp;
    end
    function msg = encode(obj,t,omega_square)
      msg = crazyflie_t.crazyflie_thrust_t();
      thrust = min(65000,10000*(sqrt(omega_square)+obj.a)-32768);
      thrust = max(0,thrust);
      msg.thrust1 = thrust(1);
      msg.thrust2 = thrust(2);
      msg.thrust3 = thrust(3);
      msg.thrust4 = thrust(4);
      msg.timestamp = t;
    end
    function d = dim(obj)
      d = 4;
    end
    function str = timestampName(obj)
      str = 'timestamp';
    end
    function names = coordinateNames(obj)
      names = {'thrust1','thrust2','thrust3','thrust4'};
    end
  end

end
