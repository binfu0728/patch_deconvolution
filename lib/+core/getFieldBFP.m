% Generate the electric field at the conjugate back focal plane of the
% objective due to an isotropic psf at different Z
% author: Bin Fu, bf341@cam.ac.uk

function E_bfp = getFieldBFP(Z,system)
% input  : Z, the z-position of the emitter in object space (in m)
%          system, structure datatype, config contains the parameters related to system (lenses, sampling rate, camera spec, etc.)
% output : E_bfp, The electric field at the back focal plane

    NA = system.NA; %numerical aperture of the objective
    wavelength = system.wavelength; %peak wavelength emission (in m)
    n_medium   = system.n_medium; %refractive index of the sample medium
    n_immersion = system.n_immersion; %refractive index of the immersion oil
    cam_xscale = system.xscale; %how much the image is larger compared to back focal plane (bfp) size in x direction (e.g., image is 1000x1000, bfp is 800x400, then xscale is 1.25)
    cam_yscale = system.yscale; %how much the image is larger compared to back focal plane (bfp) size in y direction (e.g., image is 1000x1000, bfp is 800x400, then yscale is 2.5)
    cam_size   = system.imsz; %size of an image

    % get field for isotropic emitter in the origin (x,y,z)=(0,0,0) of object space
    Nx = cam_size(2); % number of pixels on x (column)
    Ny = cam_size(1); % number of pixels on y (row)
    E_bfp = ones(Ny,Nx);

    % get polar coordinates in pupil and the aperture mask
    rho_max = NA/n_medium;
    [x,y]   = meshgrid(linspace(-rho_max*cam_xscale,rho_max*cam_xscale,Nx),...
                       linspace(-rho_max*cam_yscale,rho_max*cam_yscale,Ny));
    [phi,rho] = cart2pol(x,y);
    aperture  = rho < rho_max*(n_medium/n_immersion);

    % move emitter in object space in z direction by adding defocus
    k0      = 2*pi/wavelength;
    phase_z = n_medium*k0*Z*sqrt(1 - rho.^2);
    total_phase = phase_z; % psf is spatially invariant, x and y phase is not necessary
    E_bfp   = E_bfp.*exp(1j*total_phase);

    % field outside the pupil is zero
    E_bfp = E_bfp.*aperture;
    E_bfp(isnan(E_bfp)) = 0;
    % figure;imshow(aperture);
end
