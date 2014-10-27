classdef ViconLCMCoder < LCMCoder

    methods
        function [x,t] = decode(obj.data)
            msg = vicon_t.vicon_pos_t(data);
            x = zeros(12,1);
            x(1:6) = msg.q;
            t = msg.timestamp;
        end
        function msg = encode(obj,t,x)
            msg = vicon_t.vicon_pos_t();
            msg.q = x(1:6);
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
