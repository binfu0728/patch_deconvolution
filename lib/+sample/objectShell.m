% Generate a sphere shell with sub-resolution voxel size for later
% resamling
% Author: Bin Fu, bf341@cam.ac.uk

function shell = objectShell(voxel_size,radius,thickness,sample_range,shape)
% input  : voxel_size, float, size of the voxel (in m)
%          radius, float, radius of the sampled object (in m)
%          thickness, float, thickness of the object (in m)
%          sample_range, float, axial sampling range of the object (in m), should be the same as the psf
%          shape, shape of the object, can be sphere, cube, cylinder and grid
% output : shell, the result volume
    if nargin < 5
        shape = 'sphere';
    end
    
    x_range = sample_range/voxel_size; %width of the laterial information
    y_range = sample_range/voxel_size; %height of the laterial information
    z_range = sample_range/voxel_size; %depth of the axial information
    o = round([x_range y_range z_range]/2); % origin
    [x,y,z] = meshgrid((1:round(x_range)),(1:round(y_range)),(1:round(z_range)+1));
    switch shape
        case 'sphere'
            r = sqrt((x-o(1)).^2+(y-o(2)).^2+(z-o(3)).^2);
            r = r*voxel_size;
            shell = r<(radius+thickness/2) & r>(radius-thickness/2);       
        case 'cube'
            x=x-o(1);y=y-o(2);z=z-o(3);
            shell = abs(x*voxel_size)<(radius+thickness/2) & abs(z*voxel_size)<(radius+thickness/2) & abs(y*voxel_size)<(radius+thickness/2);
            tempt = abs(x*voxel_size)<(radius-thickness/2) & abs(z*voxel_size)<(radius+thickness/2) & abs(y*voxel_size)<(radius-thickness/2);
            shell = shell-tempt;
        case 'cylinderXY'
            x=x-o(1);y=y-o(2);z=z-o(3);
            shell = sqrt(x.^2+y.^2)*voxel_size<(radius+thickness/2) & sqrt(x.^2+y.^2)*voxel_size>(radius-thickness/2) & abs(z*voxel_size)<radius;
        case 'cylinderXZ'
            x=x-o(1);y=y-o(2);z=z-o(3);
            shell = sqrt(x.^2+z.^2)*voxel_size<(radius+thickness/2) & sqrt(x.^2+z.^2)*voxel_size>(radius-thickness/2) & abs(y*voxel_size)<radius;
        case 'grid'
            shell = zeros(ceil(y_range), round(x_range), round(z_range));
            period = round((-radius:2*thickness:radius)/voxel_size);
            for i = 1:length(period)-1
                init_pos = period(i)+o(3);
                shell(round(-radius/voxel_size)+o(1):round(radius/voxel_size)+o(1),round(-radius/voxel_size)+o(1):round(radius/voxel_size)+o(1),...
                       init_pos:init_pos+round(thickness/voxel_size)-1) = 1;
            end
        otherwise
            disp('Not supported');
    end 
end