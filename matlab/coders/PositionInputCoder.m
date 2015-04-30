classdef PositionInputCoder < LCMCoder
  properties
  end
    
  methods
    function [input,t] = decode(obj,data)
      msg = crazyflie_t.crazyflie_positioninput_t(data);
      input = msg.input;
      t = msg.timestamp;
    end
    
    function msg = encode(obj,t,input)
      msg = crazyflie_t.crazyflie_positioninput_t();   
      msg.input = input;
      msg.timestamp = t;
    end
    
    function d = dim(obj)
      d = 7;
    end
    
    function str = timestampName(obj)
      str = 'timestamp';
    end
    
    function names = coordinateNames(obj)
      names = {'desiredroll','desiredpitch','desiredyaw','desiredomegax','desiredomegay','desiredomegaz','thrust'};
    end
  end

end