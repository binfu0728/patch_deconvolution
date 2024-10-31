% Generate a colour-coded projection of a stack of images.

function img_rgb = getColourcodedHyperstack(stack)
    numFrames = size(stack,3);
    colours = fliplr(jet(numFrames)); % CHANGE COLORMAP HERE (replace jet)
    img_rgb = zeros(size(stack,1),size(stack,2),3);
    for i=1:numFrames
        r = colours(i,1)*stack(:,:,i);
        g = colours(i,2)*stack(:,:,i);
        b = colours(i,3)*stack(:,:,i);
        img_rgb = img_rgb + cat(3,r,g,b);
    end
    img_rgb = img_rgb/max(img_rgb(:));
end