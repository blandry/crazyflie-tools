q = rand(6,1);
qd = rand(6,1);
u = abs(rand(4,1))*10+10;

cf = Crazyflie;
r = cf.manip;

ani_dyn = sodynamics(0,q,qd,u)
my_dyn = CrazyflieModel(0,[q;qd],u,1,1,1,1,1,1)
urdf_dyn = r.dynamics(0,[q;qd],u)
err_ani_me = my_dyn-ani_dyn
err_urdf_me = my_dyn-urdf_dyn