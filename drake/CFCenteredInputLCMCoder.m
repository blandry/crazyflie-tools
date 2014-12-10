classdef CFCenteredInputLCMCoder < LCMCoder

    methods
        function [u,t] = decode(obj,data)
            msg = crazyflie_t.crazyflie_thrust_t(data);
            u = [msg.thrust1 msg.thrust2 msg.thrust3 msg.thrust4]';
            t = msg.timestamp;
        end
        function msg = encode(obj,t,u)
            u = u+50000;
            u = min(u,64000);
            u = max(u,0);
            msg = crazyflie_t.crazyflie_thrust_t();
            msg.thrust1 = u(1)-32768;
            msg.thrust2 = u(2)-32768;
            msg.thrust3 = u(3)-32768;
            msg.thrust4 = u(4)-32768;
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
