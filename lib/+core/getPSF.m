% Simulating the system psf for the Fourier light field
% author: Bin Fu, bf341@cam.ac.uk

function psf = getPSF(imsz,system,array_centre,flag)
% input  : imsz, size of fourier light field image
%          camera, structure datatype, config contains the parameters related to camera 
%          system, structure datatype, config contains the parameters related to system (lenses, sampling rate, etc.)
%          array_centre, manually selected centres for the microlens array. Empty for using the default microlens array centre
%          flag, show the process of psf simulating and the figure of the MLA position and phase 
% output : psf, the point spread function of the system

    if nargin < 3
        array_centre = [];
        flag = 0;
    end

    system.bfp_radius = system.f_obj*system.NA*(system.f_fl/system.f_tube); %calculate the radius of the back focal plane size (in m)
    bfp_diameter  = 2*system.bfp_radius/system.cam_pixsize; %px
    system.imsz   = imsz;
    system.xscale = imsz(2)/bfp_diameter; %how much the image is larger compared to back focal plane (bfp) size in x direction (e.g., image is 1000x1000, bfp is 800x400, then xscale is 1.25)
    system.yscale = imsz(1)/bfp_diameter; %how much the image is larger compared to back focal plane (bfp) size in y direction (e.g., image is 1000x1000, bfp is 800x400, then yscale is 2.5)

    if ~isempty(array_centre)
        array_centre = (array_centre - flip(imsz)/2) / (system.bfp_radius/system.cam_pixsize); %convert unit from pixel to m
    end

    if flag == 1
        f1 = figure('position',[100 100 600 600]);
    end

    %%%%%%% core section start %%%%%%%
    Z   = -system.axial_range/2:system.axial_rate:system.axial_range/2; %sampling frequency in Z, i.e., the z-position of the emitter in object space (in m)
    psf = zeros(imsz(1),imsz(2),length(Z));
    
    % get phase added by the microlens array
    phase_MLA = core.getPhaseMLA(system,array_centre,flag);

    for i = 1:length(Z)
        % get electric field in pupil due to an isotropic emitter in point (x,y,z)
        E_bfp = core.getFieldBFP(Z(i),system);

        % apply mla phase
        E_bfp = E_bfp.*exp(1j*phase_MLA);

        % propagate to image plane
        E_img = core.propagateFresnelTF(E_bfp,system);

        % get intensities
        I_img = abs(E_img.^2);
        psf(:,:,i) = I_img;

        if flag == 1
            figure(f1);imshow(flipud(I_img),[]);title('z = '+string(round(Z(i)*1e9))+' nm');
            pause(0.001);
        end      
    end
    %%%%%%% core section end %%%%%%%

    psf = (psf-min(psf(:)))./max(psf(:))-min(psf(:));

    if flag == 1
        % get coloured psf projection
        colourPSF = core.getColourcodedHyperstack(psf); imshow(3*colourPSF); set(gca,'YDir','normal');
    end
end