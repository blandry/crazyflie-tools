options.floating=true;
r=RigidBodyManipulator('crazyflie.urdf',options); 
r=r.addRobotFromURDF('cannon.urdf', [], [], options);