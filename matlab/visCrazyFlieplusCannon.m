options.floating=true;
r=RigidBodyManipulator('crazyflie.urdf',options); 
r=r.addRobotFromURDF('cannon.urdf', [], [], options);
v = r.constructVisualizer();
vicon_frame = LCMCoordinateFrame('VortexCannon-40gal',TwoRobotViconCoder,'x');
vicon_frame.addTransform(AffineTransform(vicon_frame,v.getInputFrame,eye(6),zeros(6,1)));
v = v.inInputFrame(vicon_frame);
runLCM(v,[]);