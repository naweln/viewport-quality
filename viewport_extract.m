function [ viewport ] = viewport_extract(panorama, azimuth, elevation, width, height, fov_v)
%VIEWPORT returns extracted viewport given panorama, azimuth and elevation
    % maybe change so that fov and viewport size can also be modified?

% Example script to extract viewport from spherical image and its 
% panoramic representation.
% francesca.desimone@epfl.ch

% panorama parameters
dim = size(panorama);
im_w = dim(2); % nb columns, real pixel width = im_w/pix_size
im_h = dim(1); % nb rows, real pixel height = im_h/pix_size
pix_size = 5; 

az_degree = -azimuth;
el_degree = elevation;
angle_degree = 0;

% viewport resolution in matlab matrix unit. 
vp_w = width; %Real pixel width = vp_w/pix_size
vp_h = height; %Real pixel height = vp_h/pix_size


% sphere
% longitude = theta [-pi, pi]
s_theta = linspace(-pi,pi,(im_w/pix_size));
% latitude = phi [-pi/2, pi/2]
s_phi = linspace(pi/2,-pi/2,ceil(im_w/(pix_size*2)));
[LO,LA] = meshgrid(s_theta, s_phi);
% spherical to cartesian coordinates (LHS)
[Xs,Ys,Zs] = sph2cart(LO,LA,1);


% viewport
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

% Extract pixel value from equirectnagular image for each (theta, phi)
% and assign it to corresponding (x0,y0,z0) pixel in viewport

% theta and phi corresponding to each pixel in panoramic image (associated
% to pixel centers)
im_theta = linspace(0+pi/im_w,2*pi-pi/im_w,im_w); % is this associated to center?? ***
%im_theta = linspace(0,2*pi-2*pi/im_w,im_w); Or this??
im_phi = linspace(0+pi/(2*im_h),pi-pi/(2*im_h),im_h);


%% bilinear interpolation

% creation of image used for interpolation: borders are obtained by copying
% borders in original pano (padding)
interp_pano = zeros(im_h+2, im_w+2);
interp_pano(2:end-1, 1) = panorama(:,1);
interp_pano(2:end-1, end) = panorama(:, end);
interp_pano(1, 2:end-1) = panorama(1, :);
interp_pano(end, 2:end-1) = panorama(end, :);
interp_pano(1,1) = panorama(1,1);
interp_pano(1,end) = panorama(1,end);
interp_pano(end, 1) = panorama(end, 1);
interp_pano(end, end) = panorama(end,end);
interp_pano(2:end-1, 2:end-1) = panorama;

viewport = interp2(interp_pano, theta*im_w/(2*pi), phi*im_h/pi);

return

