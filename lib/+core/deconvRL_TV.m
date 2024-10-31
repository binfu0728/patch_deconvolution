% The CPU kernel for applying Richardon-Lucy deconvolution on the Fourier light
% field image.
% author: Bin Fu, bf341@cam.ac.uk

function [volume,error] = deconvRL_TV(I,iter,J,OTF,OTFm)
% input  : I, The original Fourier light field image 
%          iter, the iterations to perform RL deconvolution  
%          J, the initialized volume for the reconstruction
%          OTF, the Fourier transform of the system psf
%          OTFm, the Fourier transform of the mirrored system psf (according to RL deconvolution paper, the psf used in the backprojection is mirrored, i.e.,psf(-x,-y,-z))
% output : volume, The reconstructed volume
%          error, The cost function of the RL deconvolution
    I = double(I);
    error = zeros(1,iter);
    lambda = 0.005;
    for i = 1:iter
        fpj       = forwardProjection(OTF,J); % forward projection
        % figure;imshow(fpj,[]);
        errorBack = I./fpj; % find the error between current forward-projected image and the original image
        errorBack = max(errorBack,0); % positive constraint
        bpjError  = backProjection(OTFm,errorBack); % backward projection 
        error(i)  = sum(bpjError,'all'); % calculate cost function
        [grad_x, grad_y, grad_z] = compute_gradient_3d(J);
        grad_magnitude = sqrt(grad_x.^2 + grad_y.^2 + grad_z.^2);
        % Avoid division by zero
        grad_magnitude(grad_magnitude == 0) = 1e-10;

        % Normalize the gradient
        norm_grad_x = grad_x ./ grad_magnitude;
        norm_grad_y = grad_y ./ grad_magnitude;
        norm_grad_z = grad_z ./ grad_magnitude;

        div = compute_divergence_3d(norm_grad_x, norm_grad_y, norm_grad_z);

        J = J.*bpjError./(1 - lambda * div); % update the reconstruction volume from the error
        i
    end
    volume = J;
end

function fpj = forwardProjection(OTF, volume)
    fpj = zeros([size(volume,1), size(volume,2)]);
    for k = 1:size(OTF,3)
        fpj = fpj + real(ifft2(OTF(:,:,k).*fft2(volume(:,:,k)))); % Image = ift(OTF(z) x volume(z))
    end
end

function bpj = backProjection(OTFm, image)
    bpj = zeros(size(OTFm));
    for k = 1:size(OTFm,3)
        bpj(:,:,k) = real(ifft2(OTFm(:,:,k).*fft2(image))); % Volume(z) = ift(mirrored OTF(z) x image)
    end
end

function [grad_x, grad_y, grad_z] = compute_gradient_3d(image)
% Compute the gradient of the image in x, y, and z directions
    grad_x = zeros(size(image));
    grad_y = zeros(size(image));
    grad_z = zeros(size(image));

    grad_x(1:end-1, :, :) = image(2:end, :, :) - image(1:end-1, :, :);
    grad_y(:, 1:end-1, :) = image(:, 2:end, :) - image(:, 1:end-1, :);
    grad_z(:, :, 1:end-1) = image(:, :, 2:end) - image(:, :, 1:end-1);
end

function div = compute_divergence_3d(grad_x, grad_y, grad_z)
% Compute the divergence of the gradients in 3D
    div = zeros(size(grad_x));

    div(2:end, :, :) = div(2:end, :, :) + grad_x(2:end, :, :) - grad_x(1:end-1, :, :);
    div(:, 2:end, :) = div(:, 2:end, :) + grad_y(:, 2:end, :) - grad_y(:, 1:end-1, :);
    div(:, :, 2:end) = div(:, :, 2:end) + grad_z(:, :, 2:end) - grad_z(:, :, 1:end-1);
end