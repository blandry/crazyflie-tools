% Load sysid data
load sysIdDataAll.mat

% Shift data to take into account delay
delay = 0*ones(1,4);
z = nkshift(z,delay); % Shift to take into account delay 

% Model
FileName = 'CrazyFlieModel';
Order = [6, 4, 12]; % [Number of observed outputs, Number of inputs, Number of states] 

% Initial parameters (guess)
Parameters = [1 1 1 1];

InitialStates = randn(12,1); % This is unnecessary (ignore the randn)
Ts = 0; % Continuous time model

nlgr = idnlgrey(FileName, Order, Parameters, InitialStates, Ts); 

% % Regularization: you probably won't need this
% nlgr.Algorithm.Regularization.Lambda = 0.01; % 0.01
% nlgr.Algorithm.Regularization.Nominal = 'model';
% RR = diag([ones(1,length(Parameters)) 0.001*ones(1,length(z.ExperimentName)*12)]);
% RR(7,7) = RR(7,7)*10;
% nlgr.Algorithm.Regularization.R = RR;
% nlgr.Algorithm.Criterion = 'Det';
% nlgr.Algorithm.Weighting = diag([0.1 0.1 0.1 0.1 1 0.1]);


setinit(nlgr, 'Fixed', {false false false false false false false false false false false false});   % Estimate the initial state.
% setinit(nlgr, 'Fixed', {true true true true true true true true true true true true});   % Don't estimate the initial state.


% Set max/min limits for parameters
% nlgr.Parameters(1).Minimum = -5; nlgr.Parameters(1).Maximum = 5; 
% nlgr.Parameters(2).Minimum = -5; nlgr.Parameters(1).Maximum = 5; 

% Grey box model sysid with pem
nlgr = pem(z, nlgr, 'display', 'Full','MaxIter',200); % , 'Focus','Prediction');

% Get parameters from sysid results
Parameters = [];
for k = 1:length(nlgr.Parameters)
Parameters = [Parameters;nlgr.Parameters(k).Value];
end
% save initParams.mat Parameters

% Fitted model
nlgr = idnlgrey(FileName, Order, Parameters, nlgr.InitialStates, Ts);

% Make plots comparing simulations of fitted model with training data
compare(z, nlgr);

% % Test on other data (set to true if we want this)
% test = false;
% 
% if test
%     % Test on other data
%     ztest = merge(zJan14_00,zJan14_01);
%     ztest = nkshift(ztest,delay);
%     compare(ztest,nlgr);
% end



