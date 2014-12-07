function plotq(file_num,qstar)

if (nargin<2)
    qstar = 2;
end

data = load(strcat(num2str(file_num),'.mat'));
t = data.crazyflie_input(:,6);
pos = data.crazyflie_input(:,2:5);

plot(t,pos(:,qstar));
%ylim([-10,10]);

end

