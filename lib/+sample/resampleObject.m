% Resample the object from high resolution to low resolution version that
% is suitable for the forward imaging simulation process
% Author: Bin Fu, bf341@cam.ac.uk
function object = resampleObject(vol,voxel_size,lateral_sampling_rate,axial_sampling_rate,dim)
% input  : shell, 3d array, 3d sub-resolution object
%          voxel_size, float, size of the voxel (in m)
%          lateral_sampling_rate, float, the lateral sampling rate, should be at most 1/2 of the system diffraction limit (in m)
%          axial_sampling_rate, float, axial sampling rate, should be at most 1/2 of the system diffraction limit  (in m)
%          sample_range, float, axial sampling range of the object (in m), should be the same as the range in psf
%          dim, size of the simualted PSF to make sure resampled object has the same size as PSF
% output : object, resampled object    

    xyratio  = lateral_sampling_rate/voxel_size; zratio = axial_sampling_rate/voxel_size;
    object = imresize3(double(vol),[floor(size(vol,1)/xyratio),floor(size(vol,2)/xyratio),floor(size(vol,3)/zratio)]); %method2
    object = sample.padObject(object,dim);
    object(object<0.1) = 0; %eliminate precision error from doule data type from imresize3, 0.1 is an arbitrary value
end