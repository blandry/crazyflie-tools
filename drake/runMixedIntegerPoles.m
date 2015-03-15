function runMixedIntegerPoles

cf = Crazyflie();
r = cf.manip;

terrain = RigidBodyFlatTerrain();
r = r.setTerrain(terrain);

degree = 3;
n_segments = 5;
start = [0;0;.25];
goal = [3;0;1.5];

r = addRobotFromURDF(r, 'ball.urdf');
r = compile(r);

lb = [-1;-1;.1];
ub = [1;1;3];

seeds = [...
         start';
         goal';
         ]';
n_regions = 3;

runMixedIntegerEnvironment(r, start, goal, lb, ub, seeds, degree, n_segments, n_regions, 2);

return;