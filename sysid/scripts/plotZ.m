function plotZ(file_num)
data = load(strcat(num2str(file_num),'.mat'));
t = data.CrazyFlieV3(:,8);
pos = data.CrazyFlieV3(:,2:7);
plot(t,pos(:,3));
end

