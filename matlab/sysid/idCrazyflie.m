% Load sysid data
load sysidData.mat

% Model
FileName = 'CrazyflieModel';
Order = [6, 4, 12]; % [Number of observed outputs, Number of inputs, Number of states] 

%Parameters = [1 1 1 1 1];
Parameters = [66.71 26.59 0.00 1.00 46.37];

Ts = 0; % Continuous time model

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
InitialStates{7} = [];
InitialStates{8} = [];
InitialStates{9} = [];
InitialStates{10} = [];
InitialStates{11} = [];
InitialStates{12} = [];
for i = 1 : length(x0_dat)
  InitialStates{1} = [ InitialStates{1} x0_dat{i}(1) ];
  InitialStates{2} = [ InitialStates{2} x0_dat{i}(2) ];
  InitialStates{3} = [ InitialStates{3} x0_dat{i}(3) ];
  InitialStates{4} = [ InitialStates{4} x0_dat{i}(4) ];
  InitialStates{5} = [ InitialStates{5} x0_dat{i}(5) ];
  InitialStates{6} = [ InitialStates{6} x0_dat{i}(6) ];
  InitialStates{7} = [ InitialStates{7} 0 ];
  InitialStates{8} = [ InitialStates{8} 0 ];
  InitialStates{9} = [ InitialStates{9} 0 ];
  InitialStates{10} = [ InitialStates{10} 0 ];
  InitialStates{11} = [ InitialStates{11} 0 ];
  InitialStates{12} = [ InitialStates{12} 0 ];
end

nlgr = idnlgrey(FileName, Order, Parameters, InitialStates, Ts); 
compare(z, nlgr);
return;

% Regularization
nlgr.Algorithm.Regularization.Lambda = 0.01;
nlgr.Algorithm.Regularization.Nominal = 'model';
RR = diag([.01 .01 .01 .01 .01 .01*ones(1,length(z.ExperimentName)*12)]);
nlgr.Algorithm.Regularization.R = RR;

setinit(nlgr, 'Fixed', {false false false false false false false false false false false false});

% Set max/min limits for parameters
nlgr.Parameters(1).Minimum = 0;
nlgr.Parameters(2).Minimum = 0; 
nlgr.Parameters(3).Minimum = 0;
nlgr.Parameters(4).Minimum = 0; 
nlgr.Parameters(5).Minimum = 0;
%nlgr.Parameters(6).Minimum = 0;
nlgr.Parameters(1).Maximum = 100;
nlgr.Parameters(2).Maximum = 100; 
nlgr.Parameters(3).Maximum = 100;
nlgr.Parameters(4).Maximum = 100;
nlgr.Parameters(5).Maximum = 100;
%nlgr.Parameters(6).Maximum = 100;

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
nlgr = pem(z,nlgr,'display','Full','MaxIter',60);

disp(' ------------- Initial States -------------');
displayNlgr(nlgr.InitialStates);
disp(' ------------- Parameters -------------');
displayNlgr(nlgr.Parameters);

% x0_out = zeros(12,length(z.ExperimentName));
% for i = 1:12
%   x0_out(i,:) = nlgr.InitialStates(i).Value;
% end
% compare_options = compareOptions('InitialCondition',x0_out);

% Fitted model
nlgr = idnlgrey(FileName, Order, nlgr.Parameters, nlgr.InitialStates, Ts);
% Make plots comparing simulations of fitted model with training data
figure(5);
compare(z, nlgr);