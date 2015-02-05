% Plane plant
addpath('../OnlinePlanning');
p = SBachPlant;

% When to start doing state estimation
x_launch = -0.55; % m controller is triggered at -0.5 m

disp('Starting state estimation.');

% Initialize state variables
s_last = [];
u_last = zeros(4,1);
t_last = [];
s_new = zeros(12,1);

% lcm stuff
lc = lcm.lcm.LCM.getSingleton();
aggregator = lcm.lcm.MessageAggregator();
aggregator.setMaxMessages(1);  % make it a last-message-only queue

lc.subscribe('SBach_x',aggregator); 

storage = LCMStorage('DSM_DIRECT_MATLAB');

% Vicon dt
dt = 1/120; % 120 Hertz

% Debugging
s_all = [];
s_raw = [];
t_all = [];

% Estimator loop
while true
    % Get x,y,z,roll,pitch,yaw and u
    msg = getNextMessage(aggregator);  % will block until receiving a message
    msg = fixie_state.vicon_t(msg.data);
    
    if ~isempty(msg)
        msg_q = msg.q;
        % Note sign flips here
        x =  msg_q(1); % Comes in m
        y = -msg_q(2); % +y is now to the right
        z = -msg_q(3); % +z is now down
        eulerX =  msg_q(4); % Euler angles (XYZ)
        eulerY = -msg_q(5); % sign flip 
        eulerZ = -msg_q(6); % sign flip
        t = msg.timestamp/1000; % Comes in ms
        
        % Convert euler angles to roll-pitch-yaw
        rpy = quat2rpy(angle2quat(eulerX,eulerY,eulerZ,'XYZ'));
        roll = rpy(1);
        pitch = rpy(2);
        yaw = rpy(3);
               
        % Get control
        umsg = storage.GetLatestMessage(100);
        
        if ~isempty(umsg)
            umsg = fixie_actuator.commands_t(umsg.data); 
            
            u = umsg.commands;
                
        else
            u = u_last;
        end
        
        % Initialize state estimate lcm message
        statemsg = fixie_state.xhat_t();
        
        % Compute derivatives of positions, angles
        if (~isempty(s_last))

            if (abs(t-t_last) > eps)
                % Use constant dt here since that leads to cleaner velocity
                % estimates
                xdot = (x-s_last(1))/dt;
                ydot = (y-s_last(2))/dt;
                zdot = (z-s_last(3))/dt;
                rolldot = (roll-s_last(4))/dt;
                pitchdot = (pitch-s_last(5))/dt;
                yawdot = (yaw-s_last(6))/dt;  
                
%                 xdot = (x-s_last(1))/(t-t_last);
%                 ydot = (y-s_last(2))/(t-t_last);
%                 zdot = (z-s_last(3))/(t-t_last);
%                 rolldot = (roll-s_last(4))/(t-t_last);
%                 pitchdot = (pitch-s_last(5))/(t-t_last);
%                 yawdot = (yaw-s_last(6))/(t-t_last);   
                
            else
                xdot = 0;
                ydot = 0;
                zdot = 0;
                rolldot = 0;
                pitchdot = 0;
                yawdot = 0;
            end
            
            % Compute U,V,W from xdot,ydot,zdot
            R_body_to_world = rpy2rotmat(rpy);
            R_world_to_body = R_body_to_world';
            UVW = R_world_to_body*[xdot;ydot;zdot];

            % Compute P,Q,R (angular velocity components)
            pqr = rpydot2angularvel(rpy,[rolldot;pitchdot;yawdot]);
            PQR = R_world_to_body*pqr; % body coordinate frame

            % See if vicon dropped out and set Luenberger gain
            % accordingly
            if abs(x) > 100
                L = 0; % i.e. ignore current state est. and use model only
            else
                L = 0.3; % Luenberger gain
            end

            if s_last(1) > x_launch % (If plane has reached point where controller is triggered)
               % Do prediction with model
               sdot_pred = p.dynamics(0,s_last,u_last);
               s_new = s_last + dt*(sdot_pred) + L*([x;y;z;roll;pitch;yaw;UVW;PQR] - s_last);
               if abs(x) < 100 % Vicon has it
                s_new = [x;y;z;roll;pitch;yaw;s_new(7:12)]; % Use x,y,z, etc. from optotrak (i.e. only estimate velocities)
               end
            else  % (Otherwise don't use model for prediction)
               s_new = [x;y;z;roll;pitch;yaw;UVW;PQR];
            end
            
        else
            s_new = zeros(12,1);
%             % Debugging
            U = 0;V=0;W=0;P=0;Q=0;R=0;
            UVW = [0;0;0]; PQR = [0;0;0];
        end
        
        % Save these state estimates for use in next iteration
        s_last = s_new;
        u_last = u;
        t_last = t;
        
        statemsg.xhat = s_new;
        statemsg.timestamp = msg.timestamp;
        
        % Debugging
        t_all(end+1) = msg.timestamp/1000;
        s_all(:,end+1) = s_new;
        s_raw(:,end+1) = [s_new(1:6);UVW;PQR];


        % Publish state message
        lc.publish('SBach_xhat', statemsg);
                
    end
    
    
    
    

end