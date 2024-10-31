% get patches from a FLFM image
% author: Bin Fu, bf341@cam.ac.uk

function patchImg = getPatch(img,patchSize,centreOfViews)
% input  : img, the FLFM image
%          patchSize, size of cropped patch for each view
%          centreOfViews, centre of each views in the FLFM image for creating patches
% output : patchImg, A series of images for each views seperately

    numOfViews = size(centreOfViews,1);
    patchImg   = zeros(patchSize,patchSize,numOfViews,'single');

    for i = 1:numOfViews
        r = centreOfViews(i,2);
        c = centreOfViews(i,1);
        patchImg(:,:,i) = img(r-patchSize/2:r+patchSize/2-1,c-patchSize/2:c+patchSize/2-1,:);
    end
end