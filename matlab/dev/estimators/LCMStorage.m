classdef LCMStorage < handle
    % Class used to do updates to controllers in a parallel, online way, by
    % storing gains in an LCM message and allowing asycronous updates to
    % that message.
    %
    % In other words, if you have an LCM channel you want the latest
    % information from, but you don't want to have to run a while(true)
    % loop waiting for it, you can set up a lcmStorage class and it will
    % always return the lastest message on that channel, regardless of if
    % there has been one since you last called.
    %
    % This class must derive from handle since it needs to store state
    % based on the last LCM message.
    %
    % The threading is very clean since it uses LCM's Java implementation
    % to deal with all of the threading externally.
    %
    % Example usage:
    %
    % <pre>
    % In object properties:
    %   properties
    %       ...
    %       lcm_storage
    %       ...
    %   end
    % In constructor:
    %   ...
    %   obj.lcm_storage = LCMStorage('my_lcm_channel_name');
    %   ...
    %
    % In control function:
    %   ...
    %   msg_from_my_channel = obj.lcm_storage.GetLatestMessage();
    %   ...
    % </pre>
    
    properties
        last_msg; % Last lcm message
        have_message = false; % Boolean representing if a message has ever been received
        
        % structure for caller to store values. While there are no
        % functions for this property, it may still be in use by users.
        % ie
        % <pre>
        %   lcm_storage.storage_struct = mystruct
        %   ... long time later ...
        %  my_old_values = lcm_storage.storage_struct; 
        % </pre>
        storage_struct;
        
        lc; % LCM object
        aggregator; % LCM aggregator object
    end
    
    
    methods
        function obj = LCMStorage(lcmChannel)
            % Constructor for LCMStorage
            %
            % @param lcmChannel full name of the LCM channel on which
            % to listen
            
            checkDependency('lcm');
            
            obj.lc = lcm.lcm.LCM.getSingleton();
            obj.aggregator = lcm.lcm.MessageAggregator();
            
            obj.lc.subscribe(lcmChannel, obj.aggregator);
            obj.aggregator.setMaxMessages(1);
            
            obj.storage_struct = struct();
            
            
        end
        
        function msg = GetLatestMessage(obj, timeout)
            % Checks for a new LCM message and return the latest message,
            % be that a new one or the one returned last time.  Will
            % <b>block</b> if it has never seen a message on the LCM channel
            % and timeout is unset.
            %
            % @param timeout timeout for if you have never seen an LCM
            % message.  Will return [] if the timeout is reached.
            %   @default -1 (block until message received)
            %
            % @retval msg latest LCM message
            
            if (nargin < 2)
                timeout = -1;
            end

            
            % check the LCM buffer for a new message
            if (numMessagesAvailable(obj.aggregator) > 0 || obj.have_message == false)
                % get the new message
                obj.last_msg = getNextMessage(obj.aggregator, timeout); % block if no messages
                obj.have_message = true;
            end
            
            msg = obj.last_msg;
        end
        
    end
    
end
