classdef CFInputFromDrakeLCMCoder < LCMCoder

    methods
        function [u,t] = decode(obj,data)
            msg = crazyflie_t.crazyflie_thrust_t(data);
            u = [msg.thrust1 msg.thrust2 msg.thrust3 msg.thrust4]';
            t = msg.timestamp;
        end
        function msg = encode(obj,t,u)
            % u is from the Drake model and is
            % actually omega^2
            a = -1.499999942623626e+04;
            msg = crazyflie_t.crazyflie_thrust_t();
            msg.thrust1 = (sqrt(u(1))+a)-32768;
            msg.thrust2 = (sqrt(u(2))+a)-32768;
            msg.thrust3 = (sqrt(u(3))+a)-32768;
            msg.thrust4 = (sqrt(u(4))+a)-32768;
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
