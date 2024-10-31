% calculating OTF and the mirrored OTF based on psf
% author: Bin Fu, bf341@cam.ac.uk

function [OTF,OTFm] = calcOTF(psf)
% input  : psf, a 3d matrix representing the system transfer function 
% output : OTF, the Fourier transform of the psf
%          OTFm, the Fourier transform of the mirrored psf (according to RL deconvolution paper, the psf used in the backprojection is mirrored, i.e.,psf(-x,-y))
    OTFm = flip(psf,2); %mirror in x direction
    OTFm = flip(OTFm,1); %mirror in y direction
    OTF  = fftshift(psf,1);
    OTF  = fftshift(OTF,2);
    OTFm = fftshift(OTFm,1);
    OTFm = fftshift(OTFm,2);

    for ii = 1:size(OTF,3)
        OTF(:,:,ii)  = fft2(OTF(:,:,ii)); % PSF to OTF
        OTFm(:,:,ii) = fft2(OTFm(:,:,ii)); % PSF to OTF
    end
end