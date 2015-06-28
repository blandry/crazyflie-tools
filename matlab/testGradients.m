
n = 10;

model = QuadWindPlant();
xs = rand(13,n);
us = rand(4,n);

for i=1:n
  [f1,df1]=geval(1,@(t,x,u)dynamics(model,t,x,u),0,xs(:,i),us(:,i),struct('grad_method','user'));
  [f2,df2]=geval(1,@(t,x,u)dynamics(model,t,x,u),0,xs(:,i),us(:,i),struct('grad_method','numerical'));
  if any(any(abs(f1-f2)>1e-5))
    error('dynamics when computing gradients don''t match!');
  end
  max(max(abs(df1-df2)))
  if any(any(abs(df1-df2)>1e-2))
    error('gradients don''t match!');
  end
end