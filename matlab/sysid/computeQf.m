acc = crazyflie_imu(:,5:7);
acczeroed = acc-repmat(mean(acc),size(acc,1),1);

Qf = cov(acczeroed)

t = crazyflie_imu(:,9);
fitx = fitlm(t,acc(:,1));
fity = fitlm(t,acc(:,2));
fitz = fitlm(t,acc(:,3));

predx = fitx.Coefficients.Estimate(2)*t+fitx.Coefficients.Estimate(1);
predy = fity.Coefficients.Estimate(2)*t+fity.Coefficients.Estimate(1);
predz = fitz.Coefficients.Estimate(2)*t+fitz.Coefficients.Estimate(1);

hold on
plot(t,predx,t,predy,t,predz)
plot(t,acc(:,1),t,acc(:,2),t,acc(:,3))

Qbf = cov([predx,predy,predz])