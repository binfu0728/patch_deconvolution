% Calculate the expected centre positions from microlens array (MLA)
% author: Bin Fu, bf341@cam.ac.uk

function [x,y,centreOfViews] = getCentresMLA(system)
    array_pitch = system.array_pitch; %pitch of the microlenses (in m) for hexagonal array, the distance between two side (not corners)
    array_rot   = system.array_rot; %angle (in degrees, not radians) of the rotation of the MLA, counter-clockwise
    array_direction = system.array_direction; %direction of microglens array,'horizontal' or 'vertical'
    bfp_radius = system.f_obj*system.NA*(system.f_fl/system.f_tube); %calculate the radius of the back focal plane size (in m)
    n_ulenses  = (2*bfp_radius)/array_pitch; % number of microlenses in the bfp

    % Generate centers of hexagonal lenses, pretending pitch = 1
    x     = 0:1:3*n_ulenses; % Generate more than needed, because gets cropped when rotated
    [x,y] = meshgrid(x,x);
    if strcmp(array_direction,'horizontal') % rows shift
        shift = repmat([0 0.5],[length(x),ceil(length(x)/2)]);
        shift = shift(1:length(x),1:length(x));
        x     = x + shift';
        y     = sqrt(3)/2*y;
    end
    if strcmp(array_direction,'vertical') % columns shift
        shift = repmat([0;0.5],[ceil(length(y)/2),length(y)]);
        shift = shift(1:length(y),1:length(y));
        y     = y + shift';
        x     = sqrt(3)/2*x;
    end
    x = x(:) - mean(x(:));
    y = y(:) - mean(y(:));

    % shift MLA such that center of a lens is in the center of the bfp
    dist = sqrt(x.^2 + y.^2);
    idx  = find(dist == min(dist(:)));
    x    = x - x(idx(1));
    y    = y - y(idx(1));
    
    % scale to physical units in bfp space (not yet normalised to pupil diameter)
    % factor sqrt(3)/2 due to the difference in diameter and height of the hexgonal
    x = x*array_pitch*sqrt(3)/2;
    y = y*array_pitch*sqrt(3)/2;
  
    % Rotate by an angle 'array_rot' around the center of the bfp
    array_rot = array_rot*pi/180;
    x = x.*cos(array_rot) - y*sin(array_rot);
    y = x.*sin(array_rot) + y*cos(array_rot);
    
    centreOfViews = [x,y]/bfp_radius;
    centreOfViews(sqrt(centreOfViews(:,1).^2 + centreOfViews(:,2).^2)>1,:) = [];
    centreOfViews = round(centreOfViews*bfp_radius/system.cam_pixsize);
end