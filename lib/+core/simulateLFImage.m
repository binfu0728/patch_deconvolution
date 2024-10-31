% Simulate the FLFM image
% author: Bin Fu, bf341@cam.ac.uk

function LFimg = simulateLFImage(object,psf)  
% input  : object, object in voxel with the same matrix size as psf, 3d
%          psf, the point spread function of the system in voxel, 3d
% output : LFimg, simulated Fourier light field image, 2d

    dims      = size(object);
    layer_img = zeros(dims);
    
    for i = 1:dims(3)
        layer_img(:,:,i) = conv2(object(:,:,i),psf(:,:,i),'same'); %light-sheet data conv PSF_FLFM
    end
    LFimg = sum(layer_img,3);
    LFimg = 1000*(LFimg - min(LFimg(:))) ./ (max(LFimg(:))-min(LFimg(:)));
end