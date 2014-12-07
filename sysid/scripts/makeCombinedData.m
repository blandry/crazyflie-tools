T = [
4.5 7;
5.5 8;
5 7.5;
3 5.5;
4.5 7;
4 6;
];

for i=1:size(T,1)
t0 = T(i,1);
tf = T(i,2);
rawdata = load(strcat(num2str(i),'.mat'));
data = combine(t0,tf,rawdata.proptest2,rawdata.crazyflie_input);
%save(strcat('data/1205/delaymatlabclean/',num2str(i),'.mat'),'data');
save(strcat(num2str(i),'.mat'),'data');
end
