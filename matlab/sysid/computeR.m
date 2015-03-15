t = crazyflie_state_estimate(:,15);
xyz = crazyflie_state_estimate(:,2:4);
dxyz = crazyflie_state_estimate(:,8:10);

%plot(t,dxyz);

xyz = xyz - repmat(mean(xyz),size(xyz,1),1);
dxyz = dxyz - repmat(mean(dxyz),size(dxyz,1),1);

R = cov([xyz,dxyz])