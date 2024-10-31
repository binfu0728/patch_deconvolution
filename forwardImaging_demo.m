% simulating fourier light field image
clear;clc;addpath('lib');
system    = load.loadJSON('config.json'); %loading related parameters for simulation
plotflag  = 1; %whether to show the simulation process

% psf simulation
psf = core.getPSF([1000,1000],system,[],plotflag); %psf simualtion

%% Sample simulation
system.lateral_rate = system.axial_rate; %assume xy-plane sampling rate is the same as the z-axis sampling rate
voxel_size = 30e-9; %high resolution sample
radius     = 7e-6;  %sample radius
thickness  = 0.5e-6;  %sample shell thickness
object = sample.objectShell(voxel_size,radius,thickness,system.axial_range,'sphere'); %simulated sample
object = sample.resampleObject(object,voxel_size,system.lateral_rate,system.axial_rate,size(psf)); %resampled the object to have the same xyz sampling rate as the psf

%% light field simulation
img = core.simulateLFImage(object,psf);
figure;
imshow(img,[]);

%% save the simulated result
load.Tifwrite(img,'test.tif');