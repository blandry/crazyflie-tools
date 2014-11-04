classdef Crazyflie
    properties
        input_frame = LCMCoordinateFrameWCoder('crazyflie_input',4,'u',CFInputLCMCoder);
        input_freq = 200;
    end

    methods
        function run(obj, utraj, tspan)
            utraj = setOutputFrame(utraj,obj.input_frame);
            if (nargin<3)
                options.tspan = utraj.tspan;
                if (options.tspan(1)<0)
                    options.tspan(1) = 0;
                end
            else
                options.tspan = tspan;
            end
            options.input_sample_time = 1/obj.input_freq;
            runLCM(utraj,[],options);
        end
    end

end
