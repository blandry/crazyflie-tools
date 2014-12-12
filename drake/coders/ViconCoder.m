classdef ViconCoder < LCMCoder
  
  methods
    function [q,t] = decode(obj,data)
      msg = vicon_t.vicon_pos_t(data);
      q = msg.q;
      t = msg.timestamp;
    end
    function msg = encode(obj,t,q)
      msg = vicon_t.vicon_pos_t();
      msg.q = q;
      msg.timestamp = t;
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
