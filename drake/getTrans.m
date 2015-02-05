R = rotz(sym(pi/4));
syms eulerRollActualRad eulerPitchActualRad eulerYawActualRad real
rpy = [eulerRollActualRad eulerPitchActualRad eulerYawActualRad]';
rpyPrime = simplify(rotmat2rpy(rpy2rotmat(rpy) * R));
eulerC = ccode(rpyPrime)
syms gyrox gyroy gyroz real
gyro = [gyrox gyroy gyroz]';
gyroPrime = R*gyro;
omegaC = ccode(gyroPrime)