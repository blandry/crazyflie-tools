function drawLCMPolytope(A, b, id, highlight, lc)
if nargin < 5
  lc = lcm.lcm.LCM.getSingleton();
end
if nargin < 4
  highlight = false;
end
if nargin < 3
  id = 1;
end

msg = crazyflie_t.polytopes_t();
msg.id = id;
msg.highlighted = highlight;
msg.remove = false;
if id ~= 0
  V = iris.thirdParty.polytopes.lcon2vert(A,b)';
  msg.num_vertices = size(V,2);
  msg.V = V;
else
  msg.remove = true;
end
lc.publish('DRAW_POLYTOPE', msg);

end