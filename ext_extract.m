function external = ext_extract(panorama, azimuth,elevation,vert_inside, wrap_flag)

im_h = size(panorama,1);
im_w = size(panorama,2);

theta = linspace(-pi+pi/im_w,3*pi-pi/im_w,2*im_w);
phi = linspace(-pi/2+pi/(2*im_h),3*pi/2-pi/(2*im_h),2*im_h);

% external (enclosing) rectangle (and concactenation of 2 sides)
%viewing direction
viewing_x = pi + deg2rad(azimuth);
viewing_y = pi/2 - deg2rad(elevation);
%discrete theta and phi corresponding to viewing direction
viewing_theta = discrete(viewing_x, theta);
viewing_phi = discrete(viewing_y, phi);
% conversion from angle to row, col indices for viewing direction
viewing_row = floor(viewing_phi*im_h/pi);
viewing_col = floor(viewing_theta*im_w/(2*pi));

% determining horizontal boundaries for the external rectangle
max_row = viewing_row;
min_row = viewing_row;
if max_row > im_h; max_row = im_h; end
if min_row < 1; min_row = 1; end
for i=1:im_w
    row = find(vert_inside(:,i)==1);
    if(~isempty(row))
        if(row(end) > max_row); max_row = row(end); 
        elseif (row(1) < min_row); min_row = row(1);
        end
    end
end

% determining max and min col for external rectangle
if(isempty(find(wrap_flag==1,1))) % no wrapping
    max_col = viewing_col;
    min_col = viewing_col;
    for i=1:im_h
        col = find(vert_inside(i,:)==1);
        if(~isempty(col))
            if(col(end) > max_col); max_col = col(end); 
            elseif (col(1) < min_col); min_col = col(1);
            end
        end    
    end
else % portion wraps around
    temp(1:im_h,1:im_w/2) = vert_inside(:,im_w/2+1:end);
    temp(1:im_h,im_w/2+1:im_w) = vert_inside(:,1:im_w/2);
    if(viewing_col > im_w/2)
        max_col = viewing_col;
        min_col = viewing_col;
    else
        max_col = viewing_col + im_w/2;
        min_col = viewing_col + im_w/2;
    end
    for i=1:im_h
        col = find(temp(i,:)==1);
        if(~isempty(col))
            if(col(end) > max_col); max_col = col(end);
            elseif (col(1) < min_col); min_col = col(1);
            end
        end
    end
    max_col = max_col - im_w/2;
    min_col = min_col + im_w/2;
end

% creating rectangular image
if(isempty(find(wrap_flag==1,1)))
    external = panorama(min_row:max_row, min_col:max_col);
else
    external(:,1:im_w-min_col+1) = panorama(min_row:max_row, min_col:im_w);
    external(:,im_w-min_col+2:im_w-min_col+1+max_col) = panorama(min_row:max_row, 1:max_col);
end
end
