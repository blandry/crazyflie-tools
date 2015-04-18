options.floating=true;
r=RigidBodyManipulator('crazyflie.urdf',options); 
r=r.addRobotFromURDF('quadrotor.urdf', [], [], options);
v = r.constructVisualizer();

state_estimator_frame = LCMCoordinateFrame('crazyflie_state_estimate',StateEstimatesCoder_OnlySix,'x');
%state_estimator_frame.addTransform(AffineTransform(state_estimator_frame,v.getInputFrame,[eye(6),zeros(6)],zeros(6,1)));

vicon_frame = LCMCoordinateFrame('VortexCannon-40gal',ViconCoder,'x');
%vicon_frame.addTransform(AffineTransform(vicon_frame,v.getInputFrame,eye(6),zeros(6,1)));

combined_frame = MultiCoordinateFrame.constructFrame({state_estimator_frame,vicon_frame});
combined_frame.addTransform(AffineTransform(combined_frame,v.getInputFrame,eye(12),zeros(12,1)));

v = v.inInputFrame(combined_frame);

runLCM(v,[]);