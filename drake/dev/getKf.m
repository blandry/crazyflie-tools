function [Kf,a] = getKf()
u = [
    10000;
    15000;
    20000;
    25000;
    30000;
    35000;
    40000;
    45000;
    50000;
    55000;
    60000;
    ];
f = [
    2.8;
    4.9;
    7.2;
    9.6;
    12.4;
    14.8;
    17.6;
    20.6;
    24;
    27.8;
    31.5;
    ];
data = [u/1E3,f/4];
c = fminunc(@(c)sqrerr(c,data),[.005, -15]);
Kf = c(1)/1E6;
a = c(2)*1E3;
plot(u,f/4,'o',u, Kf*(u-a).^2);
end

function err = sqrerr(c,dat)
k = c(1);
a = c(2);
x = dat(:,1);
ypred = k*(x-a).^2;
y = dat(:,2);
err = sum((y-ypred).^2);
end
