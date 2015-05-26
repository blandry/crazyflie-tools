strings = [
-.36 .5 .09 0 -.5 1.77;
-.36 .5 .74 -.36 -.5 .95;
-.36 .5 1.12 -.36 -.5 1.68;
-.36 .5 1.33 .36 -.5 2.29;
-.36 .5 1.6 .36 -.5 1.62;
-.36 .5 1.74 .36 -.5 1.93;
-.36 .5 2.15 -.36 -.5 1.46;
0 .5 .765 0 -.5 .795;
0 .5 1.15 .36 -.5 1.15;
0 .5 1.28 -.36 -.5 .11;
0 .5 1.42 0 -.5 1.42;
0 .5 1.78 .36 -.5 .12;
0 .5 2.05 -.36 -.5 1.835;
.36 .5 .8 -.36 -.5 1.11;
.36 .5 1.16 -.36 -.5 1.47;
.36 .5 1.61 .36 -.5 1.19;
.36 .5 2.0 .36 -.5 2.1;
-.36 .3 0 -.36 .3 2.02;
0 -.34 0 0 -.34 1.42;
.36 0 0 .36 0 2.0;
];

docNode = com.mathworks.xml.XMLUtils.createDocument('strings');
docRootNode = docNode.getDocumentElement;

for i=1:size(strings,1)
  string = strings(i,:);
  p1 = string(1:3);
  p2 = string(4:6);
  l = norm(p2-p1);
  v1 = [0 0 1];
  v2 = p2-p1;
  rpy = rotmat2rpy(vrrotvec2mat(vrrotvec(v1,v2)));
  
  link = docNode.createElement('link');
  link.setAttribute('name',strcat('string',int2str(i)));
  
  inertial = docNode.createElement('inertial');
  mass = docNode.createElement('mass');
  mass.setAttribute('value','.5');
  iorigin = docNode.createElement('origin');
  iorigin.setAttribute('rpy','0 0 0');
  iorigin.setAttribute('xyz',strcat({'0 0 '},num2str(l/2)));
  inertia = docNode.createElement('inertia');
  inertia.setAttribute('ixx','10');
  inertia.setAttribute('ixy','0');
  inertia.setAttribute('ixz','0');
  inertia.setAttribute('iyy','10');
  inertia.setAttribute('iyz','0');
  inertia.setAttribute('izz','1');
  inertial.appendChild(mass);
  inertial.appendChild(iorigin);
  inertial.appendChild(inertia);
  link.appendChild(inertial);

  visual = docNode.createElement('visual');
  vorigin = docNode.createElement('origin');
  vorigin.setAttribute('rpy','0 0 0');
  vorigin.setAttribute('xyz',strcat({'0 0 '},num2str(l/2)));
  vgeometry = docNode.createElement('geometry');
  vbox = docNode.createElement('box');
  vbox.setAttribute('size',strcat({'.002 .002 '},num2str(l)));
  vgeometry.appendChild(vbox);
  material = docNode.createElement('material');
  material.setAttribute('name','Red');
  visual.appendChild(vorigin);
  visual.appendChild(vgeometry);
  visual.appendChild(material);
  link.appendChild(visual);
  
  collision = docNode.createElement('collision');
  corigin = docNode.createElement('origin');
  corigin.setAttribute('rpy','0 0 0');
  corigin.setAttribute('xyz',strcat({'0 0 '},num2str(l/2)));
  cgeometry = docNode.createElement('geometry');
  cbox = docNode.createElement('box');
  cbox.setAttribute('size',strcat({'.002 .002 '},num2str(l)));
  cgeometry.appendChild(cbox);
  collision.appendChild(corigin);
  collision.appendChild(cgeometry);
  link.appendChild(collision);
  
  docRootNode.appendChild(link);
  
  joint = docNode.createElement('joint');
  joint.setAttribute('name',strcat('string',int2str(i),'_weld'));
  joint.setAttribute('type','fixed');
  parent = docNode.createElement('parent');
  parent.setAttribute('link','world');
  child = docNode.createElement('child');
  child.setAttribute('link',strcat('string',int2str(i)));
  jorigin = docNode.createElement('origin');
  jorigin.setAttribute('rpy',strcat(num2str(rpy(1)),{' '},num2str(rpy(2)),{' '},num2str(rpy(3))));
  jorigin.setAttribute('xyz',strcat(num2str(p1(1)),{' '},num2str(p1(2)),{' '},num2str(p1(3))));
  joint.appendChild(parent);
  joint.appendChild(child);
  joint.appendChild(jorigin);
  
  docRootNode.appendChild(joint);
end

xmlFileName = ['strings','.xml'];
xmlwrite(xmlFileName,docNode);
type(xmlFileName);