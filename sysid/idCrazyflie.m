% Load sysid data
load sysidData.mat

% Model
FileName = 'CrazyflieModel';
Order = [6, 4, 12]; % [Number of observed outputs, Number of inputs, Number of states] 

% Initial parameters [Ixx,Iyy,Izz,Km]
Parameters = [1 1 1 1];

% InitialStates = randn(12,1);
Ts = 0; % Continuous time model

% % extract inital state guesses from the data
if iscell(z.OutputData)
  for i = 1:length(z.OutputData)
    x0_dat{i} = z.OutputData{i}(1,:);
  end
  num_data = length(z.OutputData);
else
  x0_dat{1} = z.OutputData(1,:);
  num_data = 1;
end
InitialStates{1} = [];
InitialStates{2} = [];
InitialStates{3} = [];
InitialStates{4} = [];
InitialStates{5} = [];
InitialStates{6} = [];
for i = 1 : length(x0_dat)
  InitialStates{1} = [ InitialStates{1} x0_dat{i}(1) ];
  InitialStates{2} = [ InitialStates{2} x0_dat{i}(2) ];
  InitialStates{3} = [ InitialStates{3} x0_dat{i}(3) ];
  InitialStates{4} = [ InitialStates{4} x0_dat{i}(4) ];
  InitialStates{5} = [ InitialStates{5} x0_dat{i}(5) ];
  InitialStates{6} = [ InitialStates{6} x0_dat{i}(6) ];
end
InitialStates{7} = zeros(1,num_data);
InitialStates{8} = zeros(1,num_data);
InitialStates{9} = zeros(1,num_data);
InitialStates{10} = zeros(1,num_data);
InitialStates{11} = zeros(1,num_data);
InitialStates{12} = zeros(1,num_data);

nlgr = idnlgrey(FileName, Order, Parameters, InitialStates, Ts); 

% Regularization
nlgr.Algorithm.Regularization.Lambda = 0.01;
nlgr.Algorithm.Regularization.Nominal = 'model';
RR = diag([ones(1,length(Parameters)) 0.01*ones(1,length(z.ExperimentName)*12)]);
nlgr.Algorithm.Regularization.R = RR;

% setinit(nlgr, 'Fixed', {true true true true true true false false false false false false});   % Estimate velocities initial states
setinit(nlgr, 'Fixed', {false false false false false false false false false false false false}); % Estimate the initial state.

% Set max/min limits for parameters
nlgr.Parameters(1).Minimum = 0; nlgr.Parameters(1).Maximum = 1000; 
nlgr.Parameters(2).Minimum = 0; nlgr.Parameters(2).Maximum = 1000; 
nlgr.Parameters(3).Minimum = 0; nlgr.Parameters(3).Maximum = 1000; 

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

x0_out = zeros(12,length(z.ExperimentName));
for i = 1:12
  x0_out(i,:) = nlgr.InitialStates(i).Value;
end
compare_options = compareOptions('InitialCondition',x0_out);

% Fitted model
nlgr = idnlgrey(FileName, Order, Parameters, nlgr.InitialStates, Ts);
% Make plots comparing simulations of fitted model with training data
figure(5);
compare(z, nlgr, compare_options);