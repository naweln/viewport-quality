function [x_pano, y_pano] = inverse_gnomonic(x_vp, y_vp, az_degree, el_degree)
% given a point in radians on viewport (where the center of the viewport is 
% point (0,0), it finds the correspoding point in radians on the panorama.

rho = sqrt(x_vp.^2 + y_vp.^2);
c = atan(rho);

x_pano = deg2rad(az_degree) + pi + atan2(x_vp.*sin(c), ...
         rho.*cos(c).*cos(deg2rad(el_degree))- ...
         y_vp.*sin(deg2rad(el_degree)).*sin(c));
y_pano = pi/2 - asin(cos(c).*sin(deg2rad(el_degree))+...
         (y_vp.*sin(c).*cos(deg2rad(el_degree)))./rho);


if x_vp == 0; x_pano = az_degree; end;
if y_vp == 0; y_pano = el_degree; end;

