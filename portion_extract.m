function [pano_portion, vert_inside, wrap_flag] = portion_extract(panorama, azimuth, elevation, fov_v, fov_h)
%PANORAMA_EXTRACT Summary of this function goes here
%   Detailed explanation goes here
% to do: implement 'angle', internal rectangle

if(elevation >= 90-rad2deg(fov_v/2) | elevation <= -90+rad2deg(fov_v/2))
    angle_flag = 1;
else angle_flag= 0;
end
if(elevation > 0); polar_flag = 1; % closer to north pole
else               polar_flag = -1; % closer to south pole
end

dim = size(panorama);
im_w = dim(2); % nb columns
im_h = dim(1); % nb rows

% upper line
size_vect = 2*im_w;
x_vp = linspace(-tan(fov_h/2), tan(fov_h/2), size_vect);
y_vp = tan(fov_v/2)*ones(1, size_vect);
[x_p_up, y_p_up] = inverse_gnomonic(x_vp, y_vp, azimuth, elevation);

%lower line
x_vp = linspace(-tan(fov_h/2), tan(fov_h/2), size_vect);
y_vp = -tan(fov_v/2)*ones(1, size_vect);
[x_p_down, y_p_down] = inverse_gnomonic(x_vp, y_vp, azimuth, elevation);

% left line
x_vp = -tan(fov_h/2)*ones(1, size_vect);
y_vp = linspace(-tan(fov_v/2), tan(fov_v/2), size_vect);
[x_p_left, y_p_left] = inverse_gnomonic(x_vp, y_vp, azimuth, elevation);

% right line
x_vp = tan(fov_h/2)*ones(1, size_vect);
y_vp = linspace(-tan(fov_v/2),tan(fov_v/2), size_vect);
[x_p_right, y_p_right] = inverse_gnomonic(x_vp, y_vp, azimuth, elevation);

% pano coordinates
theta = linspace(-pi+pi/(im_w),3*pi-pi/(im_w),2*im_w);
phi = linspace(pi/(2*im_h),pi-pi/(2*im_h),im_h);

% finding the discrete thetas and phis corresponding to border
up_theta    = discrete(x_p_up, theta);
up_phi      = discrete(y_p_up, phi);
down_theta  = discrete(x_p_down, theta);
down_phi    = discrete(y_p_down, phi);
right_theta = discrete(x_p_right, theta);
right_phi   = discrete(y_p_right, phi);
left_theta  = discrete(x_p_left, theta);
left_phi    = discrete(y_p_left, phi);

%removing repeated points
[up_theta, up_phi] = reduce(up_theta, up_phi);
[down_theta, down_phi] = reduce(down_theta, down_phi);
[right_theta, right_phi] = reduce(right_theta, right_phi);
[left_theta, left_phi] = reduce(left_theta, left_phi);

% wrapping if theta > 2pi or theta < 0
% calculating row index of pano based on phi
up_row = ceil(up_phi*im_h/pi);
down_row = ceil(down_phi*im_h/pi);
left_row = ceil(left_phi*im_h/pi);
right_row = ceil(right_phi*im_h/pi);

wrap_flag = zeros(1,im_h); % indicates which rows have been wrapped

i = find(left_theta > 2*pi);
wrap_flag(left_row(i)) = 1;
left_theta(i) = left_theta(i) - 2*pi;
i = find(left_theta < 0);
wrap_flag(left_row(i)) = 1;
left_theta(i) = left_theta(i) + 2*pi;

i = find(right_theta > 2*pi);
wrap_flag(right_row(i)) = 1;
right_theta(i) = right_theta(i) - 2*pi;
i = find(right_theta < 0);
wrap_flag(right_row(i)) = 1;
right_theta(i) = right_theta(i) + 2*pi;

i = find(up_theta > 2*pi);
wrap_flag(up_row(i)) = 1;
up_theta(i) = up_theta(i) - 2*pi;
i = find(up_theta < 0);
wrap_flag(up_row(i)) = 1;
up_theta(i) = up_theta(i) + 2*pi;

i = find(down_theta > 2*pi);
wrap_flag(down_row(i)) = 1;
down_theta(i) = down_theta(i) - 2*pi;
i = find(down_theta < 0);
wrap_flag(down_row(i)) = 1;
down_theta(i) = down_theta(i) + 2*pi;

% conversion from angles to col indices (row already done)
up_col = ceil(up_theta*im_w/(2*pi));
down_col = ceil(down_theta*im_w/(2*pi));
left_col = ceil(left_theta*im_w/(2*pi));
right_col = ceil(right_theta*im_w/(2*pi));

if(polar_flag == 1) [up_col, up_row] = fill_line(up_col,up_row, im_w); end
if(polar_flag == -1) [down_col, down_row] = fill_line(down_col,down_row, im_w); end

% checking valid points (points inside border)
pano_portion = zeros(im_h, im_w);
vert_inside = zeros(im_h, im_w);
for i=1:im_w
    for j=1:im_h
        index_up    = find(up_col == i);
        index_down  = find(down_col == i);
        index_left  = find(left_col == i);
        index_right = find(right_col == i);
        if(isempty(index_up) & isempty(index_down) & isempty(index_left) & isempty(index_right))
            vert_inside(j,i) = 0;
        else
            vert_inside(j,i) = check_vertical(j,i, polar_flag, angle_flag,...
                                     up_row,    up_col,...
                                     down_row,  down_col,...
                                     left_row,  left_col,...
                                     right_row, right_col);
        end                      
        if(vert_inside(j,i))
             pano_portion(j,i) = panorama(j,i);
        end
     end
end
end



