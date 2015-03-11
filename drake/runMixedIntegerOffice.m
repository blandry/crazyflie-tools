function runMixedIntegerOffice
% Run the mixed-integer SOS trajectory planner in the office environment

cf = Crazyflie();
terrain = RigidBodyFlatTerrain();
terrain = terrain.setGeometryColor([0, 170, 255]'/256);
cf.manip = cf.manip.setTerrain(terrain);

degree = 3;
n_segments = 7;
start = [-2.5;9;1.5];
goal = [0;2;.5];

cf.manip = addRobotFromURDF(cf.manip, 'office.urdf');

lb = [-5;0;0.01];
ub = [6;9.5;2.01];

seeds = [...
        [-2.25,8,1.5]; % inside the window
         start';
         goal';
         ]';
n_regions = 7;

runMixedIntegerEnvironment(cf.manip, start, goal, lb, ub, seeds, degree, n_segments, n_regions, 0.5);

return;