function unwrapped_data = plotCleanData(file_num)

file = load(strcat(num2str(file_num),'.mat'));
t = file.data(:,1);
u = file.data(:,2:5);
q = [file.data(:,6:8),unwrap(file.data(:,9:11))];
%q = [file.data(:,6:8),file.data(:,9:11)];

unwrapped_data = [t,u,q];

figure(5)
subplot(2,1,1);
plot(t,u);
subplot(2,1,2);
plot(t,q);
%plot(t,[u,q]);
%ylim([-1,1]);

end

