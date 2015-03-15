function [Kf,b,KfSigma,bSigma] = fitKfandBParams()
% finds Kf from the model
% omega^2 = u+b
% thrust = Kf*omega^2
% weight(grams) = (1000/g)*Kf*(u+b)

r1 = [
5.118 15.7;
10.236 24.6;
15.354 33.8;
20.078 45.0;
];

r2 = [
0 0.4;
0.5905 5.2;
1.5748 8.4;
3.1496 12.0;
4.5275 14.45;
6.299 17.5;
8.0709 20.1;
9.055 22.0;
10.039 23.7;
12.2047 27.2;
14.1732 30.9;
16.1417 35.1;
18.1102 39.3;
20.07 45.0;
];

r3 = [
0 0.35;
0.3937 4.72;
1.5748 8.00;
2.9527 11.18;
4.527 14.3;
8.2677 20.6;
9.8425 23.0;
11.4173 25.48;
13.1889 29.5;
15.9448 34.5;
19.2913 41.5;
];

r4 = [
0 0.37;
5.3149 15.9;
7.874 20.1;
9.6457 23.0;
12.0079 27.0;
14.1732 30.7;
16.338 35.1;
18.1102 39.0;
20.0787 43.2;
];

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

% 7 and 8 had a B_OFFSET of 3 (onboard)
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

exp = {r1,r2,r3,r4};
exp = {r5,r6};
exp = {r7,r8};
exp = {r9};

Kfs = zeros(1,numel(exp));
bs = zeros(1,numel(exp));

x0 = [1,1];
for i=1:numel(exp);
  data = exp{i};
  
  w = warning('off','optim:fminunc:SwitchingMethod');
  params = fmincon(@(x)modelfit(x,data),x0,[-1 0],0,[],[],[],[],[],struct('Display','off'));
  warning(w);
  
  figure(1);
  subplot(numel(exp),1,i);
  plot(data(:,1),data(:,2),'b*',data(:,1),evalparams(params,data(:,1)),'r');
  legend('original data','model prediction');
  title(sprintf('Experiment #%d',i));
  
  Kfs(i) = params(1);
  bs(i) = params(2);
end

Kf = mean(Kfs);
KfSigma = std(Kfs);

b = mean(bs);
bSigma = std(bs);

% plot the final model
figure(2)
hold on
for i=1:numel(exp)
  data = exp{i};
  plot(data(:,1),data(:,2),'bo');
end
% uses the sample points of the last exp
plot([0;data(:,1);25],evalparams([Kf,b],[0;data(:,1);25]),'r');
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
  b = params(2);
  w = (1000/g)*Kf*(u+b);
end
