function [Kf,a,KfSigma,aSigma] = fitKfParams()
% finds Kf and a from the model
% omega = u-a
% thrust = Kf*omega^2
% weight(grams) = (1000/g)*Kf*(u-a)^2
% note that we also scale the input by 10000 for easier modeling

r1 = [
10000	0.6;
15000	1.2;
20000	1.9;
25000	2.6;
30000	3.4;
35000	4.1;
40000	5;
45000	6;
50000	7.1;
55000	8.1;
60000	9.2];

r2 = [
10000	0.6;
15000	1.1;
20000	2;
25000	2.7;
30000	3.5;
35000	4.4;
40000	5.2;
45000	6.3;
50000	7.5;
55000	8.7;
60000	9.8];

r3 = [
10000	0.6;
15000	1.2;
20000	1.9;
25000	2.5;
30000	3.4;
35000	4.1;
40000	4.8;
45000	5.8;
50000	7;
55000	8.1;
60000	9.2];

r4 = [
10000	0.6;
15000	1.1;
20000	2.1;
25000	2.7;
30000	3.6;
35000	4.4;
40000	5.2;
45000	6.4;
50000	7.4;
55000	8.6;
60000	9.9];

r1(:,1) = r1(:,1)/10000;
r2(:,1) = r2(:,1)/10000;
r3(:,1) = r3(:,1)/10000;
r4(:,1) = r4(:,1)/10000;

exp = {r1,r2,r3,r4};

Kfs = zeros(1,numel(exp));
as = zeros(1,numel(exp));

x0 = [0 0];
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
  as(i) = params(2);
end

Kf = mean(Kfs);
a = mean(as);
KfSigma = std(Kfs);
aSigma = std(as);

% plot the final model
figure(2)
hold on
for i=1:numel(exp)
  data = exp{i};
  plot(data(:,1),data(:,2),'bo');
end
% uses the sample points of the last exp
plot(data(:,1),evalparams([Kf,a],data(:,1)),'r');
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
  a = params(2);
  w = (1000/g)*Kf*(u-a).^2;
end
