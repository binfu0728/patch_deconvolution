% The GPU kernel for applying Richardon-Lucy deconvolution on the Fourier light
% field image.
% author: Bin Fu, bf341@cam.ac.uk

function volume = deconvRL_GPU(I,iter,J,OTF,OTFm)
% input  : I, The original Fourier light field image 
%          iter, the iterations to perform RL deconvolution  
%          J, the initialized volume for the reconstruction
%          OTF, the Fourier transform of the system psf
%          OTFm, the Fourier transform of the mirrored system psf (according to RL deconvolution paper, the psf used in the backprojection is mirrored, i.e.,psf(-x,-y,-z))
% output : volume, The reconstructed volume
%          error, The cost function of the RL deconvolution

    % error = zeros(1,iter);
    % prepare all variables into gpu array for the processing in GPU
    % I  = gpuArray(I);
    % J  = gpuArray(J);
    % OTF  = gpuArray(OTF);
    % OTFm = gpuArray(OTFm);
    D = size(I,3);
    for i = 1:iter
        % tic;
        fpj = forwardProjection(OTF,J); % forward projection
        errorBack = I./fpj; % find the error between current forward-projected image and the original image
        errorBack = max(errorBack,0); % positive constraint
        bpjError  = backProjection(OTFm,errorBack,D); % backward projection 
        J = J.*bpjError; % update the reconstruction volume from the error
    end
    % volume = J;
    volume = gather(J);
end

function fpj = forwardProjection(OTF,volume)
    fpj = sum(real(ifft2(OTF .* fft2(volume))), 3); % Image = ift(OTF(z) x volume(z))
end

function bpj = backProjection(OTFm,image,D)
    image_fft = fft2(image);
    bpj = real(ifft2(OTFm .* repmat(image_fft, 1, 1, D)));
end

