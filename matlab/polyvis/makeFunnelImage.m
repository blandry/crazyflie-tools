function [im_funnel,figNum] = makeFunnelImage(safe_regions,camPosition,camOrientation,camUp,cameraParameters)
% Plots funnel image and makes the Matlab viewing camera have the same
% focal length as the goPro so we can take the image of the funnel and
% superimpose it on top of a goPro image.
% 
% @param funnel Element of funnel library, e.g., funnelLibrary(1).
%
% @param funnelPos Starting position of funnel, i.e., amount by which
% funnel should be shifted for plotting.
%
% @param camPosition Potision of camera in world coordinate frame.
% 
% @param camOrientation Direction in which camera is pointing.
%
% @param camUp Orientation of camera's "up" vector.
%
% @param cameraParameters Camera parameter structure from Matlab's camera
% calibration.
%
% @retval im_funnel Matlab image of funnel.

% Plot funnel
im_sz = [1920, 1080];
figNum = 99;
figure(figNum);
set(figNum,'Position',[1 1 im_sz],'Visible','Off');
% figNum = figure('Position',[100 100 im_sz],'Visible','Off');

options = struct();
options.color = 'b';
% Plot polytopes
% hold on
% sz = 0.021;
% A = [eye(3);-eye(3)];
% b = [-0.5+sz;-0.5+sz;1.25+sz;0.5+sz;0.5+sz;-1.25+sz];
% P = polytope(A,b);
% plot(P,options);
for k = 4 % 1:numel(safe_regions)
  hold on
  A = safe_regions(k).A;
  b = safe_regions(k).b;
  P = polytope(A,b);
  plot(P,options);
end
alpha(0.3);

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

% % Add some lighting
% % keyboard;
% light('Position',[3;3;0],'Style','local');
% light('Position',camPosition+0*[12;12;0],'Style','local');
% light('Position',camPosition+[-12;12;-3],'Style','local');

% camlight


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

