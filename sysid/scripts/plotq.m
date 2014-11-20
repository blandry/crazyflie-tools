function plotq(file_num,qstar)

if (nargin<2)
    qstar = 1;
end

data = load(strcat(num2str(file_num),'.mat'));
t = data.crazyflie_squ_ext(:,8);
pos = data.crazyflie_squ_ext(:,2:7);

plot(t,pos(:,qstar));
ylim([-10,10]);

end

