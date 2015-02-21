classdef InputCoder < LCMCoder
  properties
    input_type;
  end
    
  methods
    function obj = InputCoder(input_type)
      obj = obj@LCMCoder();
      obj.input_type = input_type;
    end
    
    function [input,t] = decode(obj,data)
      msg = crazyflie_t.crazyflie_input_t(data);
      input = msg.input;
      t = msg.timestamp;
    end
    
    function msg = encode(obj,t,input)
      msg = crazyflie_t.crazyflie_input_t();
      
      % the firmware has input limits,
      % but this is useful for sysid so
      % that the lcm logs match the commands sent
      % to the motors
      if (strcmp(obj.input_type,'omegasqu'))
        input = max(input,1.461452111054914);
        input = min(input,59.427221477149608);
      elseif (strcmp(obj.input_type,'32bits')||strcmp(obj.input_type,'onboardpd'))
        input = max(input,0);
        input = min(input,65000);
      end
      
      msg.input = input;
      msg.type = obj.input_type;
      msg.timestamp = t;
    end
    
    function d = dim(obj)
      d = 4;
    end
    
    function str = timestampName(obj)
      str = 'timestamp';
    end
    
    function names = coordinateNames(obj)
      names = {'input1','input2','input3','input4'};
    end
  end

end