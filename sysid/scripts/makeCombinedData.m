T = [
4.184 5.009;
3.576 4.35;
4.134 4.25;
3.926 4.526;
4.542 5.233;
4.267 5.1;
4.759 5.351;
3.384 3.667;
3.967 4.85;
3.775 4.308;
3.534 4.284;
3.609 4.301;
];

for i=1:size(T,1)
t0 = T(i,1);
tf = T(i,2);
rawdata = load(strcat(num2str(i),'.mat'));
data = combine(t0,tf,rawdata.crazyflie_squ_ext,rawdata.crazyflie_input);
save(strcat('data/1119/matlab/cleanutraj/',num2str(i),'.mat'),'data');
end
