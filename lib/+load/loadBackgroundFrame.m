% find the background frame in the image stack which can be substracted in
% the following frames
function bgFrame = loadBackgroundFrame(bgdir,img,filename)
% input  : bgdir, FOLDER directory for loading/saving the background frame
%          img, the image stack containing the background frame
%          filename, the filename of the loading image. The background will be saved as 'filename_bg.tif' 
% output : bgFrame, the background image

    prompt = "Do you want to select a background frame for the substraction (0 for no, 1 for yes, ctrl+c for exit)? ";
    selection = input(prompt);
    while selection ~= 0 && selection ~= 1
        prompt = "Wrong input, please input again (0 for no, 1 for yes, ctrl+c for exit)? ";
        selection = input(prompt);
    end

    if selection == 1 % select a background frame
        bgdir1 = fullfile(load.makeDir(bgdir),'*.tif');
        namelist = {dir(bgdir1).name}';
    
        if ~isempty(namelist)
            prompt = "Do you want to select a new background frame or select from the existed one (0 for select, 1 for use existed, ctrl+c for exit)? ";
            x = input(prompt);
            while x ~= 0 && x ~= 1
                prompt = "Wrong input, please input again (0 for select, 1 for use existed, ctrl+c for exit)? ";
                x = input(prompt);
            end
        else % no background frame saved in the current directory. have to create a new one
            x = 0; 
            disp('No available background image in the current directory. Must create a new one\n');
        end
    
        switch x
            case 0 % manually select background from the image stack
                prompt = "Please type the frame you want to use as the background frame (ctrl+c for exit): ";
                idx = input(prompt);
                while idx >= size(img,3)
                    prompt = "Index out of range, please re-type : ";
                    idx = input(prompt);
                end
                bgFrame = img(:,:,idx);
                figure;imshow(bgFrame,[]);
                [~,name,ext] = fileparts(filename); % check whether there is an extension in the input filename
                bgFilename = [name,'_bg.tif'];
                bgFilename = fullfile(bgdir,bgFilename);

                %%%%%%%% save selected centres %%%%%%%%
                load.Tifwrite(bgFrame,bgFilename);
            case 1 % load from the existed centre of views
                names  = list2name(namelist);
                names  = string(names);
                prompt = strcat("Which current file you want to choose (type the index): ",names,"(ctrl+c for exit) ");
                x1 = input(prompt);
                while x1 > length(namelist)
                    prompt = strcat("Wrong index, please type again: ",names,"(ctrl+c for exit) ");
                    x1 = input(prompt);
                end
                %%%%%%%% load existed background %%%%%%%%
                bgFrame = imread(fullfile(bgdir,namelist{x1})); 
                figure;imshow(bgFrame,[]);
        end  
    else % no background frame selected
        bgFrame = zeros(size(img,1),size(img,2));
    end
end

function name = list2name(list)
% concatenate all file names together with an index before the name 
    name = [];
    for i = 1:length(list)
        tmpt = [num2str(i),'.',list{i},' '];
        name = [name, tmpt];
    end
end