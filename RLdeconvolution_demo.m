clear;clc;addpath('lib');

%%%%%% user defined parameters %%%%%%
filename  = 'expbead.tif'; %data that will be used for reconstruction
resultdir = fullfile(pwd,'result'); %FOLDER directory for saving result
covdir    = fullfile(pwd,'cov'); %FOLDER directory for loading/saving the centre of views 
system    = load.loadJSON('config.json'); %loading related parameters for simulation
plotflag  = 1; %whether to show the simulation process
% resultdir = uigetdir(pwd); %FOLDER directory for saving result (GUI version)

%% initialization
img = load.Tifread(filename);
covFilename = []; %if this is empty, the default name will be used (i.e., centreOfViews_x.csv)
centreOfViews = load.loadCentreOfViewFile(covdir,img(:,:,1),covFilename); %use default centres, load from existed files or draw a new one

%% psf simulation
psf = core.getPSF(size(img),system,centreOfViews,plotflag);

%% RL deconvolution
[OTF,OTFm] = core.calcOTF(psf); %calculate optical transfer function from point spread function
initVol    = ones(size(OTF)); %initializd the volume for the reconstruction
resultVol  = core.deconvRL(img,10,initVol,OTF,OTFm); %Ricardson-Lucy deconvolution, change deconvRL to deconvRL_GPU to use GPU version 

%% result saving - run this section if you want to save the result
resultFilename = []; %if this is empty, the default name will be used (i.e., resultVol_x.tif)
load.saveResultVol(resultdir,resultVol,resultFilename); %save the reconstructed volume
