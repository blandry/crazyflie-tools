n = 5;

rpys = [-0.9426,   -1.9063,   -1.5640;
        0.7291,   -0.1678,   -0.9321;
        2.0787,    0.5357,    0.3124;
        2.6213,   -1.3456,    1.6160;
        1.5942,   -0.7512,    0.4261];
    
omegas = [-84.8291,  -89.2100,    6.1595;
          55.8334,   86.8021,  -74.0188;
          13.7647,   -6.1219,  -97.6196;
          -32.5755,  -67.5635,   58.8569;
          -37.7570,    5.7066,  -66.8703];

R = [0.7071 -0.7071 0; 0.7071 0.7071 0; 0 0 1]; %rotz(pi/4);

rotrpys = zeros(n,3);
rotomegas = zeros(n,3);
for i=1:n  
  rotrpys(i,:) = rotmat2rpy(rpy2rotmat(rpys(i,:)')*R)';
  rotomegas(i,:) = (R*omegas(i,:)')';
end

display(rpys);
display(omegas);
display(rotrpys);
display(rotomegas);