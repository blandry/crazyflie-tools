classdef PosEstimatorLCMCoder < LCMCoder

    methods
        function [x,t] = decode(obj,data)
            msg = crazyflie_t.crazyflie_state_estimate_t(data);
            x = msg.xhat(1:6);
            t = msg.timestamp;
        end
        function msg = encode(obj,t,x)
            msg = crazyflie_t.crazyflie_state_estimate_t();
            msg.xhat(1:6) = x;
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
