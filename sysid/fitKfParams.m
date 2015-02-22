function [Kf,KfSigma] = fitKfParams()
% finds Kf from the model
% omega^2 = u
% thrust = Kf*omega^2
% weight(grams) = (1000/g)*Kf*u

r1 = [
];

r2 = [
];

r3 = [
];

r4 = [
];

exp = {r1,r2,r3,r4};

Kfs = zeros(1,numel(exp));

x0 = 0;
for i=1:numel(exp);
  data = exp{i};
  
  w = warning('off','optim:fminunc:SwitchingMethod');
  params = fmincon(@(x)modelfit(x,data),x0,-1,0,[],[],[],[],[],struct('Display','off'));
  warning(w);
  
  figure(1);
  subplot(numel(exp),1,i);
  plot(data(:,1),data(:,2),'b*',data(:,1),evalparams(params,data(:,1)),'r');
  legend('original data','model prediction');
  title(sprintf('Experiment #%d',i));
  
  Kfs(i) = params(1);
end

Kf = mean(Kfs);
KfSigma = std(Kfs);

% plot the final model
figure(2)
hold on
for i=1:numel(exp)
  data = exp{i};
  plot(data(:,1),data(:,2),'bo');
end
% uses the sample points of the last exp
plot(data(:,1),evalparams(Kf,data(:,1)),'r');
title('Final model predictions');

end

function c = modelfit(params,data)
  w = evalparams(params,data(:,1));
  dw = w-data(:,2);
  c = dw'*dw;
end

function w = evalparams(params,u)
  g = 9.8;
  Kf = params(1);
  w = (1000/g)*Kf*u;
end
