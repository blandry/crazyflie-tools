q = rand(6,1);
qd = rand(6,1);
u = abs(rand(4,1))*10+10;

ani_dyn = sodynamics(0,q,qd,u)
my_dyn = CrazyflieModel(0,[q;qd],u,1,1,1,1,1);
my_dyn = my_dyn(7:12)
err = my_dyn-ani_dyn