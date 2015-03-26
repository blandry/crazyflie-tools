function F = superImposeFunnel(im_pic,im_funnel,alpha_param)

% close all;

% Display image
figNum = 100;
figure(figNum);
% Make it run in the background (without showing the image on the screen)
set(figNum,'Visible','Off');
clf;

imshow(im_pic);

% Plot funnel image
hold on;
h = imshow(im_funnel);

% Get cdata of funnel image
h_cdata = get(h,'cdata');

% Set transparancies using this data
alphas = alpha_param*(~(h_cdata(:,:,1) == 255)); % & (h_cdata(:,:,2) == 255) & (h_cdata(:,:,3) == 255)); 
set(h, 'AlphaData', alphas)

F = figNum;

% Get frame
% F = getframe(figNum); 

% F = im2frame(zbuffer_cdata(figNum)); % getframe(figNum);

end

function cdata = zbuffer_cdata(hfig)

% Get CDATA from hardcopy using zbuffer

% Need to have PaperPositionMode be auto 

orig_mode = get(hfig, 'PaperPositionMode');

set(hfig, 'PaperPositionMode', 'auto');

cdata = hardcopy(hfig, '-Dzbuffer', '-r0');

% Restore figure to original state

set(hfig, 'PaperPositionMode', orig_mode); % end

end