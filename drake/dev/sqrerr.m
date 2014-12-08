function err = sqrerr(c,dat)
k = c(1);
a = c(2);
x = dat(:,1);
ypred = k*(x-a).^2;
y = dat(:,2);
err = sum((y-ypred).^2);
end