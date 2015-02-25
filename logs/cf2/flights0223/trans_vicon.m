vicon_rpy = zeros(size(vicon));
for i=1:size(vicon,1)
  vicon_rpy(i,1:3) = quat2rpy(angle2quat(vicon(i,1),vicon(i,2),vicon(i,3),'XYZ'));
end
for i=2:size(vicon,1)
  vicon_rpy(i,4:6) = 120*(vicon_rpy(i,1:3)-vicon_rpy(i-1,1:3));
end