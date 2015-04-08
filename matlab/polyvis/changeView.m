function im_funnel = changeView(figNum,camPosition,camOrientation,camUp,cameraParameters)

figure(figNum);
% Make it run in the background (without showing the image on the screen)
set(figNum,'Visible','Off');

% Image size
im_sz = [1920, 1080];

% Camera properties
camera_pos = camPosition;
camera_target = camOrientation + camera_pos;

% Get focal length from intrinsic matrix of camera
% Intrinsic matrix
KK = cameraParameters.IntrinsicMatrix;
focal = KK(1,1); 
% Define field of view of the camera in degrees
% midx = im_sz(1)/2;
midy = im_sz(2)/2;
fov = 2*atand(midy/focal);

% Set the camera field of view and other view params
camva(fov);
campos(camera_pos);
camtarget(camera_target);
camproj('perspective');
camup(camUp);

% Now set axis properties
axis image
axis off
set(gca,'Units','pixels');
set(gca,'Position',[1 1 im_sz]);
set(gcf, 'Color', [1 1 1])

% Get image. We need to use zbuffer_cdata function (below) in order to
% prevent matlab from capturing everything on the screen. We only need
% stuff that's actually part of the image.
im_funnel = zbuffer_cdata(figNum);

% im_funnel = frame2im(getframe(figNum)); % drawnow;
% im_funnel = getimage(figNum);

end

function cdata = zbuffer_cdata(hfig)

% Get CDATA from hardcopy using zbuffer

% Need to have PaperPositionMode be auto 

orig_mode = get(hfig, 'PaperPositionMode');

set(hfig, 'PaperPositionMode', 'auto');

% cdata = hardcopy(hfig, '-Dzbuffer', '-r0');
cdata = hardcopy(hfig, '-dOpenGL', '-r0');

% Restore figure to original state

set(hfig, 'PaperPositionMode', orig_mode); % end

end

