% This is script is used to collect the learning and test data for all the
% images. The images themselves need to be in a folder 'images'.
% The name of the image doesn't matter. Image type should be specified at
% line 23.
clear all

%% Loop that goes through each image to calculate the RD curve for panorama
%  xand viewport

startFolder = pwd;

to_save = 1; % boolean that determines whether or not the images
             % (compressed panos, viewports) will be saved or not

vp_w_vec = [480,640,720,960,1080]; %TODO change viewport dimensions depending on size of pano
vp_h_vec = 3*vp_w_vec/4; % aspect ratio: 4:3
fov_v = 65 / 180 * pi;
    
azimuth   = linspace(-90,180,4);
elevation = linspace(-90,90,9);
mkdir('data/masks');

contents = dir('images/*.png');
for i = 1%:numel(contents)
    cd(startFolder)
    filename = contents(i).name;
    panorama = imread(['images/' filename]);
    if (size(panorama,3)~=1); panorama = rgb2gray(panorama); end
    
    vp_w = vp_w_vec(1);
    vp_h = vp_h_vec(1);
    rate_distortion_pano(filename, startFolder, panorama, azimuth, elevation, vp_w, vp_h, fov_v, to_save);
    
    for j = 1:length(vp_w_vec)
        vp_w = vp_w_vec(j);
        vp_h = vp_h_vec(j);
        
        cd(startFolder)
        rate_distortion_vp(filename, startFolder, panorama, azimuth, elevation, vp_w, vp_h, fov_v, to_save);
    end
end

cd(startFolder)

