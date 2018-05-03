close all
clear all

% Example script to extract viewport from spherical image and its 
% panoramic representation.
% francesca.desimone@epfl.ch

% General parameters - panorama

% in matlab matrix unit. Real pixel width = im_w/pix_size
im_w = 300;
% in matlab matrix unit. Real pixel height = im_h/pix_size
im_h = 150; 
% pixel size in matlab matrix unit (i.e. defines where long lat line is)
pix_size = 5; 

% General parameters - viewport 

% viewport vertical field of view
fov_v = 65 / 180 * pi; % 65 degrees in radians (degrees = rad * 180 /pi)
% viewport resolution in matlab matrix unit. Real pixel width = vp_w/pix_size
vp_w = 640;
% viewport resolution in matlab matrix unit. Real pixel height = vp_h/pix_size
vp_h = 480;

% % % viewport corresponding to 8x8 patch
% fov_v = 8*2*pi/im_w; 
% vp_w = 640;
% vp_h = 640;

% viewing direction (theta, phi) and head rotation in degrees
az_degree = 0; % pi * az / 180;
el_degree = 0; % pi * el / 180;
angle_degree = 0; % pi * angle / 180;

%% panorama

% create panoramic image with long-lat pattern

% long-lat grid
panorama = 255*ones(im_h,im_w);
% vertical lines
panorama(:,1:pix_size:im_w) = 0;
% horizontal lines
panorama(1:pix_size:im_h,:) = 0;

% show panoramic image
figure, imshow(panorama, [])

%% sphere

% long-lat pattern on the sphere

% longitude = theta [-pi, pi]
s_theta = linspace(-pi,pi,(im_w/pix_size));
% latitude = phi [-pi/2, pi/2]
s_phi = linspace(pi/2,-pi/2,ceil(im_w/(pix_size*2)));
[LO,LA] = meshgrid(s_theta, s_phi);
% spherical to cartesian coordinates (LHS)
[Xs,Ys,Zs] = sph2cart(LO,LA,1);

% spherical image
figure,
warp(Xs,Ys,Zs,panorama) % this invert Y axes
axis square
view(az_degree,el_degree)

%% Viewport

az = pi * az_degree / 180;
el = pi * el_degree / 180;
angle = pi * angle_degree / 180;

viewport = ones(vp_h,vp_w);

% viewport coordinates
[y_vp, x_vp] = meshgrid( ...
    ((1:vp_w) - 0.5) / (vp_w / 2) - 1, ... 
    1 - ((1:vp_h) - 0.5) / (vp_h / 2));

% extract viewport for given viewing direction

% viewport pixel coordinates in xyz coord system
X = ones(vp_h, vp_w);
% tan(fov_h/2) = tan(fov_v / 2) * (vp_w / vp_h);
Y = y_vp * tan(fov_v / 2) * (vp_w / vp_h);
Z = x_vp * tan(fov_v / 2);

% rotate viewport to match viewing direction
rotz_az = [cos(az) sin(az) 0; -sin(az) cos(az) 0; 0 0 1];
roty_el = [cos(el) 0 -sin(el); 0 1 0; sin(el) 0 cos(el)];
rotx_angle = [1 0 0; 0 cos(angle) sin(angle); 0 -sin(angle) cos(angle)];
R_matrix = rotz_az * roty_el * rotx_angle;
Xo = R_matrix(1,1) * X + R_matrix(1,2) * Y + R_matrix(1,3)*Z;
Yo = R_matrix(2,1) * X + R_matrix(2,2) * Y + R_matrix(2,3)*Z;
Zo = R_matrix(3,1) * X + R_matrix(3,2) * Y + R_matrix(3,3)*Z;

% Project into the equirect domain by computing the angular coordinates.
r = (Xo.^2 + Yo.^2 + Zo.^2).^0.5;
phi = acos(Zo./r);
theta = atan2(Yo, Xo);
theta = theta + pi;

% show viewport on panorama
vponpanorama = panorama; %255*ones(im_h,im_w);

% Extract pixel value from equirectnagular image for each (theta, phi)
% and assign it to corresponding (x0,y0,z0) pixel in viewport

% theta and phi corresponding to each pixel in panoramic image
% THESE SHOULD BE ASSOCIATED TO PIXEL CENTROIDS ONLY
im_theta = linspace(0,2*pi-2*pi/im_w,im_w);
%im_phi = linspace(0,pi,im_h);
im_phi = linspace(0+pi/(2*im_h),pi-pi/(2*im_h),im_h);

for row = 1:vp_h
    for col = 1:vp_w
        
        % theta and phi corresponding to pixel (row,col) in viewport
        target_theta = theta(row, col);
        target_phi = phi(row, col);
        
        % pixel value corresponding to closest value of (theta,phi) in 
        % panoramic image
        mindiff_theta = min(abs(im_theta - target_theta));
        im_col = find(abs(im_theta - target_theta) == mindiff_theta, 1);
        mindiff_phi = min(abs(im_phi - target_phi));
        im_row = find(abs(im_phi - target_phi) == mindiff_phi, 1);
        
        % assign panoramic image pixel value to viewport pixel
        viewport(row, col) = panorama(im_row,im_col);
        vponpanorama(im_row,im_col) = 128;
        
    end
end

figure, imshow(viewport, [])
figure, imshow(vponpanorama/255)
% spherical image
figure,
warp(Xs,Ys,Zs,(vponpanorama/255)) % this invert Y axes
colormap gray
axis square
view(az_degree+90,el_degree)