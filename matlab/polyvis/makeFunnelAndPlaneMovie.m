close all;

% Read video
% vid = VideoReader('/media/blandry/LinuxData/Videos/tvlqrwithobstacles/GOPR0017.MP4');
% vid = VideoReader('/media/blandry/LinuxData/Videos/tvlqrwithobstacles/GOPR0015.MP4');


% Undistort using gopro calibration parameters
load('cameraParams_1080_120_W.mat');

startFrame = 1;

% Now get camera positions
load('../../logs/cf2/tests0321/gateswobstacles6faster.mat');
xyz = mean(sbach_camera(:,2:4),1); 
euler = mean(sbach_camera(:,5:7),1);
rpy = quat2rpy(angle2quat(euler(1),euler(2),euler(3),'XYZ'));
xCam = [xyz';rpy];

% X-vector of camera
% xvec = [1;-0.03;-0.02];
xvec = [-1;0;0];
xvec = xvec/norm(xvec);

% Number of frames in video
N = vid.NumberOfFrames;

% Camera orientation
% camOrientation = [1;0;0];
R_body_to_world = rpy2rotmat(xCam(4:6));
% R_body_to_world = rpy2rotmat([xCam(4);rpy0(2);xCam(6)]);
camOrientation = R_body_to_world*xvec; % Orientation of x axis

camPosition = xCam(1:3);
% camPosition = camPosition + R_body_to_world*[0;-0.01;0];

% "Up" vector of camera
camUp = R_body_to_world*[0;0;1];

% Plot funnel (just once since camera is not
% moving)
load('../regions.mat');
[im_funnel,figNum] = makeFunnelImage(safe_regions,camPosition,camOrientation,camUp,cameraParameters);

funnelVideo = avifile(['./awesome_video.avi']);
funnelVideo.Quality = 100;
funnelVideo.Compression = 'None';

fps = vid.FrameRate;
funnelVideo.Fps = fps;

% Read all images from video
startTime = 0; % 47
endTime = 0.1; % 50; 
startInd = startFrame + startTime*120;
endInd = startFrame + endTime*120 ; 

% Break this window into 7 second chunks (because if we try to read more
% than that at a time, my computer freezes)
numFrames = endInd-startInd+1;
chunkSize = floor(fps*7); % about 7 seconds at 120 fps
numChunks = floor(numFrames/chunkSize) + 1;
chunkInds = startInd + [0:chunkSize:(numChunks-1)*chunkSize];
chunkInds = [chunkInds, endInd];


for chunk = 1:length(chunkInds)-1
    
    startInd = chunkInds(chunk);
    endInd = chunkInds(chunk+1)-1;
    
    disp('Reading frames from video...');
    ims = read(vid,[startInd endInd]);
    disp('Done reading frames.');
    
    for k = 1:(endInd-startInd+1)
        
        % Display frame number being processed
        disp(['Processing frame ' num2str(k+startInd-chunkInds(1)) ' of ' num2str(numFrames-1) ' ...']);
        
        % Load frame as image
        % im = read(vid,k);
        im = ims(:,:,:,k);
        
        % Undistort images using go pro camera params
        im_undistorted = undistortImage(im, cameraParameters);
        
        
        % Superimpose funnel image onto image from video
        F = superImposeFunnel(im_undistorted,im_funnel,0.5); % 0.65
        
        
        % Write frame to video using avifile
        funnelVideo = addframe(funnelVideo,F);
        
        
    end
    
end

% Close video object
funnelVideo = close(funnelVideo);

% ffmpeg -i funnelMovie_2015_02_20_03.avi -acodec libfaac -b:a 128k -vcodec mpeg4 -b:v 72000k -filter:v "setpts=0.25*PTS" -flags +aic+mv4 funnelMovie_2015_02_20_03.mp4

% Process for making videos after this:
% - Get this into openshot along with original raw video
% - Take audio from raw video
% - Make sure to have an extra second of audio in the beginning. This is
% because openshot creates a blip in the audio right at the beginning.
% Trim extra second using ffmpeg:
% ffmpeg -ss 00:00:01 -t 00:00:03 -i final_movie_2015_02_24_00_extra.mp4 -acodec copy -vcodec copy final_movie_2015_02_24_00.mp4







