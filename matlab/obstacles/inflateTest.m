P = Polyhedron(obs');
A = P.A;
b = P.b;
norms = sqrt(sum(A.^2,2));
A = A./repmat(norms,1,3);
b = b./norms;
b = b + .02;
P_inf = Polyhedron(A,b);
obs_inf = P_inf.V';

plot(P,'color','b',P_inf,'color','r','alpha',.5);
axis equal
xlim([-1 1])
ylim([-1 1])
zlim([-.5 3])