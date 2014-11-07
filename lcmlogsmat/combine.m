function [ data ] = combine(t0,tf,pos,input)

[~,ipos]=min(abs(pos(:,8)-t0));
[~,jpos]=min(abs(pos(:,8)-tf));
t0pos = pos(ipos,8);
tfpos = pos(jpos,8);

[~,iinput]=min(abs(input(:,6)-(t0pos-.5)));
[~,jinput]=min(abs(input(:,6)-(tfpos+.5)));
input1foh = foh(input(iinput:jinput,6)',input(iinput:jinput,2)');
input2foh = foh(input(iinput:jinput,6)',input(iinput:jinput,3)');
input3foh = foh(input(iinput:jinput,6)',input(iinput:jinput,4)');
input4foh = foh(input(iinput:jinput,6)',input(iinput:jinput,5)');
input1 = ppval(input1foh,pos(ipos:jpos,8));
input2 = ppval(input2foh,pos(ipos:jpos,8));
input3 = ppval(input3foh,pos(ipos:jpos,8));
input4 = ppval(input4foh,pos(ipos:jpos,8));

timestamps = pos(ipos:jpos,8);
N = numel(timestamps);
inputdata = [input1+32768,input2+32768,input3+32768,input4+32768];
posdata = [pos(ipos:jpos,2:4),zeros(N,3)];
ang = pos(ipos:jpos,5:7);
for i=1:N
    posdata(i,4:6) = quat2rpy(angle2quat(ang(i,1),ang(i,2),ang(i,3),'XYZ'));
end

data = [timestamps,inputdata,posdata];

end