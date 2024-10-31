% get PSF/OTF patch from a FLFM PSF
% author: Bin Fu, bf341@cam.ac.uk

function [patchOTF,patchOTFm] = getPSFPatch(psf,patchSize,centreOfViews)
% input  : psf, the FLFM psf
%          patchSize, size of cropped patch for each view
%          centreOfViews, centre of each views in the FLFM image for creating patches
% output : patchOTF, the Fourier transform of the psf for each views
%          patchOTFm, the Fourier transform of the mirrored psf (according to RL deconvolution paper, the psf used in the backprojection is mirrored, i.e.,psf(-x,-y))
    numOfViews = size(centreOfViews,1);
    patchpsf   = zeros(patchSize,patchSize,size(psf,3),numOfViews,'single');
    patchOTF   = zeros(patchSize,patchSize,size(psf,3),numOfViews,'single');
    patchOTFm  = zeros(patchSize,patchSize,size(psf,3),numOfViews,'single');
    
    for i = 1:numOfViews
        r = centreOfViews(i,2);
        c = centreOfViews(i,1);
        patchpsf(:,:,:,i) = psf(r-patchSize/2:r+patchSize/2-1,c-patchSize/2:c+patchSize/2-1,:);
    end
    
    for i = 1:numOfViews 
        [patchOTF(:,:,:,i),patchOTFm(:,:,:,i)] = core.calcOTF(patchpsf(:,:,:,i));
    end
end