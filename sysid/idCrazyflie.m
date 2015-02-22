% Load sysid data
load sysidData.mat

% Model
FileName = 'CrazyflieModel';
Order = [6, 4, 12]; % [Number of observed outputs, Number of inputs, Number of states] 

Parameters = [2.15 2.15 4.29 2.37 1];

InitialStates = [0 0 0 0 0 0 0 0 0 0 0 0]';
Ts = 0; % Continuous time model

nlgr = idnlgrey(FileName, Order, Parameters, InitialStates, Ts); 

% Regularization
nlgr.Algorithm.Regularization.Lambda = 0.01;
nlgr.Algorithm.Regularization.Nominal = 'model';
RR = diag([ones(1,length(Parameters)) 0.01*ones(1,length(z.ExperimentName)*12)]);
nlgr.Algorithm.Regularization.R = RR;

setinit(nlgr, 'Fixed', {false false false false false false false false false false false false}); % Estimate the initial state.

% Set max/min limits for parameters
nlgr.Parameters(1).Minimum = 0; nlgr.Parameters(1).Maximum = 1000; 
nlgr.Parameters(2).Minimum = 0; nlgr.Parameters(2).Maximum = 1000; 
nlgr.Parameters(3).Minimum = 0; nlgr.Parameters(3).Maximum = 1000; 
nlgr.Parameters(4).Minimum = 0; nlgr.Parameters(4).Maximum = 1000; 
nlgr.Parameters(5).Minimum = 0;

nlgr.InitialStates(1).Name = 'x';
nlgr.InitialStates(2).Name = 'y';
nlgr.InitialStates(3).Name = 'z';
nlgr.InitialStates(4).Name = 'roll';
nlgr.InitialStates(5).Name = 'pitch';
nlgr.InitialStates(6).Name = 'yaw';
nlgr.InitialStates(7).Name = 'xdot';
nlgr.InitialStates(8).Name = 'ydot';
nlgr.InitialStates(9).Name = 'zdot';
nlgr.InitialStates(10).Name = 'rolld';
nlgr.InitialStates(11).Name = 'pitchd';
nlgr.InitialStates(12).Name = 'yawd';

% Grey box model sysid with pem
nlgr = pem(z,nlgr,'display','Full','MaxIter',20);

disp(' ------------- Initial States -------------');
displayNlgr(nlgr.InitialStates);
disp(' ------------- Parameters -------------');
displayNlgr(nlgr.Parameters);

% Fitted model
nlgr = idnlgrey(FileName, Order, Parameters, nlgr.InitialStates, Ts);
% Make plots comparing simulations of fitted model with training data
figure(5);
compare(z, nlgr);