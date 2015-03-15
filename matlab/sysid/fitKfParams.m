function [Kf,KfSigma] = fitKfParams()
% finds Kf from the model
% omega^2 = u
% thrust = Kf*omega^2
% weight(grams) = (1000/g)*Kf*u

% 5 and 6 had a B_OFFSET of about 2 (onboard)
r5 = [
2.9527 6.10;
4.7244 10.80;
6.8897 15.01;
9.0551 18.64;
11.6142 22.60;
12.99 25.05;
14.7638 28.40;
16.1417 31.0;
17.3228 33.0;
19.0944 36.2;
];

r6 = [
3.937 8.6;
5.9055 12.6;
9.2519 18.76;
11.81102 23.09;
15.3543 29.75;
18.8976 36.45;
];

% 7 and 8 had a B_OFFSET of about 3 (onboard)
r7 = [
13.18897 23.3;
15.3593 27.4;
17.12598 30.8;
19.09488 34.6;
20.6693 37.9;
];

r8 = [
5.31496 10.0;
7.0866 13.6;
9.2519 17.5;
11.0236 20.3;
12.2047 22.3;
14.1732 25.2;
15.7480 28.3;
18.9133 32.3;
20.0787 36.0;
21.6535 40.0;
];

% 9 had a B_OFFSET of 2.8 (onboard)
r9 = [
4.9212 9.34;
6.2992 12.37;
7.4803 14.6;
8.8583 17.3;
10.03937 18.9;
11.4171 21.3;
13.3858 24.5;
15.1575 27.4;
16.3386 29.7;
18.3071 33.2;
20.0787 36.3;
22.2441 41.9;
];

exp = {r5,r6};
exp = {r7,r8};
exp = {r9};

Kfs = zeros(1,numel(exp));

x0 = 1;
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
plot([0;data(:,1);25],evalparams(Kf,[0;data(:,1);25]),'r');
title('Final model predictions');
xlim([0 25]);
ylim([0,45]);

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
