% Load sysid data
load sysidData.mat

% Model
FileName = 'CrazyflieModel';
Order = [6, 4, 12]; % [Number of observed outputs, Number of inputs, Number of states] 

% Initial parameters [Ixx,Iyy,Izz,Km]
Parameters = [0 0 0 0];

InitialStates = randn(12,1);
Ts = 0; % Continuous time model

nlgr = idnlgrey(FileName, Order, Parameters, InitialStates, Ts); 

% Regularization
nlgr.Algorithm.Regularization.Lambda = 0.01;
nlgr.Algorithm.Regularization.Nominal = 'model';
RR = diag([ones(1,length(Parameters)) 0.001*ones(1,length(z.ExperimentName)*12)]);
nlgr.Algorithm.Regularization.R = RR;

setinit(nlgr, 'Fixed', {false false false false false false false false false false false false});   % Estimate the initial state.

% Set max/min limits for parameters
nlgr.Parameters(1).Minimum = 0; nlgr.Parameters(1).Maximum = 1000; 
nlgr.Parameters(2).Minimum = 0; nlgr.Parameters(2).Maximum = 1000; 
nlgr.Parameters(3).Minimum = 0; nlgr.Parameters(3).Maximum = 1000; 

% Grey box model sysid with pem
nlgr = pem(z,nlgr,'display','Full','MaxIter',200);

% Get parameters from sysid results
fprintf('Parameters are:\nIxx=%f\nIyy=%f\nIzz=%f\nKm=%f\n',nlgr.Parameters(1).Value,nlgr.Parameters(2).Value,nlgr.Parameters(3).Value,nlgr.Parameters(4).Value)

% Fitted model
nlgr = idnlgrey(FileName, Order, Parameters, nlgr.InitialStates, Ts);
% Make plots comparing simulations of fitted model with training data
compare(z, nlgr);