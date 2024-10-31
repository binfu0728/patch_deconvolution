% Fresnel propogation
function u2 = propagateFresnelTF(u1,system)
% input  : u1, the electric field before Fresnel propogation  
%          system, structure datatype, config contains the parameters related to system (lenses, sampling rate, camera spec, etc.) 
% output : u2, the electric field after Fresnel propogation

    lambda     = system.wavelength;  %peak wavelength emission (in m)
    z          = system.f_u; %focal length of the microlenses in the array (in m)
    bfp_radius = system.bfp_radius; %the radius of the back focal plane (in m)
    xscale     = system.xscale; %how much the image is larger compared to back focal plane (bfp) size in x direction (e.g., image is 1000x1000, bfp is 800x400, then xscale is 1.25)
    yscale     = system.yscale; %how much the image is larger compared to back focal plane (bfp) size in y direction (e.g., image is 1000x1000, bfp is 800x400, then yscale is 2.5)
    
    [r,c] = size(u1); % get input field array size
    Lx = xscale*bfp_radius*2; % width
    Ly = yscale*bfp_radius*2; % length
    dx = Lx/c; 
    dy = Ly/r; % sample interval 
    fx = -1/(2*dx):1/Lx:1/(2*dx)-1/Lx; % freq coords
    fy = -1/(2*dy):1/Ly:1/(2*dy)-1/Ly; % freq coords
    [FX,FY] = meshgrid(fx,fy);

    H  = exp(-1j*pi*lambda*z*(FX.^2+FY.^2)); % trans func
    H  = fftshift(H); % shift trans func
    U1 = fft2(fftshift(u1)); % shift, fft src field
    U2 = H.*U1; % multiply
    u2 = ifftshift(ifft2(U2)); % inv fft, center obs field
end