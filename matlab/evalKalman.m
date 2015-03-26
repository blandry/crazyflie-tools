t = kalman_out(:,19);
out_signal = kalman_out(:,1:6);
in_signal = kalman_out(:,7:12);
true_signal = kalman_out(:,13:18);

areas = [];
in_blackout = false;
for i=1:numel(t)
  if ~in_blackout
    if (norm(in_signal(i,:))==0)
      areas = [areas; [t(i),Inf]];
      in_blackout = true;
    end
  else
    if (norm(in_signal(i,:))>0)
      areas(end,2) = t(i);
      in_blackout = false;
    end
  end
end

figure(46);
t0 = 15;
tf = 30;

subplot(3,1,1);
hold on
grey = [200/255 200/255 200/255];
for i=1:size(areas,1)
  area(areas(i,:),[100 100],'LineStyle','none','FaceColor',grey);
  h1 = area(areas(i,:),[-100 -100],'LineStyle','none','FaceColor',grey);
end
h2 = plot(t,true_signal(:,1),'g','LineWidth',5);
h3 = plot(t,out_signal(:,1),'r','LineWidth',2);
ylim([-2,1.5]);
xlim([t0 tf]);
xlabel('time (s)');
ylabel('x position (m)')
legend([h1 h2 h3],{'Optical Tracking Occlusion', 'True Position', 'Position Estimate'});

subplot(3,1,2);
hold on
grey = [200/255 200/255 200/255];
for i=1:size(areas,1)
  area(areas(i,:),[100 100],'LineStyle','none','FaceColor',grey);
  h1 = area(areas(i,:),[-100 -100],'LineStyle','none','FaceColor',grey);
end
h2 = plot(t,true_signal(:,2),'g','LineWidth',5);
h3 = plot(t,out_signal(:,2),'r','LineWidth',2);
ylim([-2,1.5]);
xlim([t0 tf]);
xlabel('time (s)');
ylabel('y position (m)')
legend([h1 h2 h3],{'Optical Tracking Occlusion', 'True Position', 'Position Estimate'});

subplot(3,1,3);
hold on
grey = [200/255 200/255 200/255];
for i=1:size(areas,1)
  area(areas(i,:),[100 100],'LineStyle','none','FaceColor',grey);
  h1 = area(areas(i,:),[-100 -100],'LineStyle','none','FaceColor',grey);
end
h2 = plot(t,true_signal(:,3),'g','LineWidth',5);
h3 = plot(t,out_signal(:,3),'r','LineWidth',2);
ylim([0,1.5]);
xlim([t0 tf]);
xlabel('time (s)');
ylabel('z position (m)')
legend([h1 h2 h3],{'Optical Tracking Occlusion', 'True Position', 'Position Estimate'});
