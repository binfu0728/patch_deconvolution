% Generate the phase of a hexagonal or square microlens array (MLA).
% author: Bin Fu, bf341@cam.ac.uk

function phase_MLA = getPhaseMLA(system,array_centre,flag)
% input  : system, structure datatype, config contains the parameters related to system (lenses, sampling rate, camera spec, etc.) 
%          array_centre, manually selected centres for the microlens array. Empty for using the default microlens array centre
%          flag, true (or 1) for show a figure of the MLA position and corresponding continuous and wrapped phase, false (or 0) to show no figure
% output : phase_MLA, phase added by the microlens array

    array_pitch = system.array_pitch; %pitch of the microlenses (in m) for hexagonal array, the distance between two side (not corners)
    f_u        = system.f_u; %focal length of the microlenses in the array (in m)
    bfp_radius = system.bfp_radius; %the radius of the back focal plane (in m)
    wavelength = system.wavelength; %peak wavelength emission (in m)
    cam_xscale = system.xscale; %how much the image is larger compared to back focal plane (bfp) size in x direction (e.g., image is 1000x1000, bfp is 800x400, then xscale is 1.25)
    cam_yscale = system.yscale; %how much the image is larger compared to back focal plane (bfp) size in y direction (e.g., image is 1000x1000, bfp is 800x400, then yscale is 2.5)
    cam_size   = system.imsz; %size of an image
        
    n_ulenses  = (2*bfp_radius)/array_pitch; % number of microlenses in the bfp

    [x,y] = core.getCentresMLA(system);
    
    if flag
        figure('position',[100 100 1600 500]);
        subplot(1,3,1)
        voronoi(x*1e3,y*1e3); axis equal; xlim([-n_ulenses n_ulenses]*array_pitch*1e3); ylim([-n_ulenses n_ulenses]*array_pitch*1e3); hold on;
        x_outline_bfp = bfp_radius*1e3*cos(0:0.1:2.1*pi);
        y_outline_bfp = bfp_radius*1e3*sin(0:0.1:2.1*pi);
        plot(x_outline_bfp,y_outline_bfp,'r');
        xlabel('x (mm)'); ylabel('y (mm)'); title('BFP plane with respect to Microlens array')
        legend('microlens centers','microlens edges (voronoi)','conjugate bfp outline','location','northeast')
        set(gca,'fontsize',10); set(0,'DefaultAxesTitleFontWeight','normal');
    end
    
    % Normalize such that the bfp radius is 1
    x = x/bfp_radius;
    y = y/bfp_radius;

    Nx = cam_size(2); % number of pixels on x (column)
    Ny = cam_size(1); % number of pixels on y 
    
    xrange = linspace(-cam_xscale,cam_xscale,Nx); %output range (column)
    yrange = linspace(-cam_yscale,cam_yscale,Ny); %output range (row)
    
    % choose whether to use default microlens array centres or using the
    % manually selected centres
    if isempty(array_centre)
        [lrf,~] = localRadiusField(xrange,yrange,[x,y]);
    else
        [lrf,~] = localRadiusField(xrange,yrange,array_centre);
    end
    
    local_radius = bfp_radius*lrf;
    k0           = 2*pi/wavelength;
    phase_MLA    = -k0/(2*f_u)*(local_radius.^2);
    
    if flag
        subplot(1,3,2)
        imshow(flipud(phase_MLA),[]); colorbar; axis on
        xlabel('x (camera pixels)'); ylabel('y (camera pixels)'); title('BFP plane with respect to camera(continuous phase)')
        hold on
        x_outline_bfp = cos(0:0.1:2.1*pi)*Nx/2/cam_xscale + Nx/2;
        y_outline_bfp = sin(0:0.1:2.1*pi)*Ny/2/cam_yscale + Ny/2;
        plot(x_outline_bfp,y_outline_bfp,'r','LineWidth',2);
        set(0,'DefaultAxesTitleFontWeight','normal');
    
        subplot(1,3,3)
        imshow(flipud(wrapTo2Pi(phase_MLA)),[]); colorbar; axis on; title('BFP plane with respect to camera(wrapped phase)')
        xlabel('x (camera pixels)'); ylabel('y (camera pixels)');
        hold on
        x_outline_bfp = cos(0:0.1:2.1*pi)*Nx/2/cam_xscale + Nx/2;
        y_outline_bfp = sin(0:0.1:2.1*pi)*Ny/2/cam_yscale + Ny/2;
        plot(x_outline_bfp,y_outline_bfp,'r','LineWidth',2);
        set(0,'DefaultAxesTitleFontWeight','normal');
    end
end

function [lrf,ids] = localRadiusField(xrange,yrange,axes)
% Returns a matrix of real numbers representing distance within xrange and yrange to nearest axis coordinate in axes
% input  : xrange, vector -lower_x_lim:dx:upper_x_lim (in column direction)
%          yrange, vector -lower_y_lim:dy:upper_y_lim (in row direction)
%          axes, m x 2 matrix where m is number of local axis coordinates
%
% output : lrf, matrix with values for radius to nearest axis
%          ids, matrix with axes index linking to axes coords list
% 
% author: Kevin O'Holleran

    [x,y] = meshgrid(xrange,yrange);
    nr = numel(yrange); %number of rows
    nc = numel(xrange); %number of cols
    num_axes = size(axes,1);

    lrf = inf(nr,nc);
    ids = zeros(nr,nc);
    for i = 1:num_axes
        xi = axes(i,1);
        yi = axes(i,2);
        r_temp  = sqrt((x-xi).^2+(y-yi).^2);
        id_temp = r_temp<lrf;
        lrf(id_temp) = r_temp(id_temp);
        ids(id_temp) = i;
    end
end