classdef Crazyflie
    properties
        input_frame = LCMCoordinateFrameWCoder('crazyflie_input',4,'u',CFInputLCMCoder);
        input_freq = 200;
    end

    methods
        function run(obj, utraj)
            utraj = setOutputFrame(utraj,obj.input_frame);
            options.tspan = utraj.tspan;
            options.input_sample_time = 1/obj.input_freq;
            runLCM(utraj,[],options);
        end
    end

end
