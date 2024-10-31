clear;clc;addpath('lib');

%%%%%% user defined parameters %%%%%%
filename  = 'test.tif'; %data that will be used for reconstruction
resultdir = fullfile(pwd,'result'); %FOLDER directory for saving result
covdir    = fullfile(pwd,'cov'); %FOLDER directory for loading/saving the centre of views 
system    = load.loadJSON('config.json'); %loading related parameters for simulation
plotflag  = 1; %whether to show the simulation process

%% initialization
img = load.Tifread(filename);
covFilename = []; %if this is empty, the default name will be used (i.e., centreOfViews_x.csv)
centreOfViews = load.loadCentreOfViewFile(covdir,img,covFilename); %use default centres, load from existed files or draw a new one

%% psf simulation
psf = core.getPSF(size(img),system,centreOfViews,plotflag);

%% patch preparation
if isempty(centreOfViews); [~,~,centreOfViews] = core.getCentresMLA(system); centreOfViews = centreOfViews + size(psf,1)/2; end %use default centres
numOfViews = 37; 
patchSize  = 130; %has to be even number

patchimg   = core.getPatch(img,patchSize,centreOfViews);
[patchOTF,patchOTFm] = core.getPSFPatch(psf,patchSize,centreOfViews);

%% RL patch deconvolution
initVol = ones(size(patchOTF(:,:,:,1))); %initialize volume for deconvolution
tic
for i = 1:numOfViews
    initVol = core.deconvRL(patchimg(:,:,i),1,initVol,patchOTF(:,:,:,i),patchOTFm(:,:,:,i));
end
ttime = toc
