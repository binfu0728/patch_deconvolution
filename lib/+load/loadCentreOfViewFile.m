% load or create the centre of views file from the specific directory
function centreOfViews = loadCentreOfViewFile(covdir,img,covFilename)
% input  : covdir, FOLDER directory for loading/saving the centre of views
%          img, the image used for centre selection 
%          covFilename, the filename for saving the selected centre of views. If this is empty, the default name will be used (i.e., centreOfViews_x.csv)
% output : centreOfViews, the coordinate (x,y)(i.e.,col,row) of the centres for each view.
    if nargin < 3
        img = [];
        covFilename = [];
    end

    prompt = "Do you want to use default psf simulation or maually selected centres for psf simulation (0 for default, 1 for manual, ctrl+c for exit)? ";
    selectcov = input(prompt);
    while selectcov ~= 0 && selectcov ~= 1
        prompt = "Wrong input, please input again (0 for default, 1 for manual, ctrl+c for exit)? ";
        selectcov = input(prompt);
    end

    if selectcov == 1 % use centres from manual selection
        covdir1 = fullfile(load.makeDir(covdir),'*.csv');
        namelist = {dir(covdir1).name}';
    
        if ~isempty(namelist)
            prompt = "Do you want to create a new centre matrix or use the existed one (0 for create, 1 for use existed, ctrl+c for exit)? ";
            x = input(prompt);
            while x ~= 0 && x ~= 1
                prompt = "Wrong input, please input again (0 for create, 1 for use existed, ctrl+c for exit)? ";
                x = input(prompt);
            end
        else % no available centre of views file in the current directory. have to create a new one
            x = 0; 
            disp('No available centre-of-view file in the current directory. Must create a new one\n');
        end
    
        switch x
            case 0 % manually select centre of views
                prompt = "Please type the number of centres you will select (ctrl+c for exit): ";
                numOfViews = input(prompt);
                figure;imshow(img,[]);hold on;

                %%%%%%%% CHANGE YOUR CURSOR COLOR HERE %%%%%%%%
                cursorcolor = [1 0 0]; 

                centreOfViews = round(core.ginput(numOfViews,cursorcolor)); 
                if isempty(covFilename) % no filename given by the user
                    covFilename = ['centreOfViews_',num2str(length(namelist)+1),'.csv']; 
                else % filename is specified by the user
                    [~,name,ext] = fileparts(covFilename); % check whether there is an extension in the input filename
                    if ~strcmp(ext,'.csv') || ~strcmp(ext,'.xlsx') % no or wrong file extension specified
                        covFilename = [name,'.csv'];
                    end
                end
                covFilename = fullfile(covdir,covFilename);
                t = array2table(centreOfViews,'VariableNames',{'x','y'});
                %%%%%%%% save selected centres %%%%%%%%
                writetable(t,covFilename);
            case 1 % load from the existed centre of views
                names  = list2name(namelist);
                names  = string(names);
                prompt = strcat("Which current file you want to choose (type the index): ",names,"(ctrl+c for exit) ");
                x1 = input(prompt);
                while x1 > length(namelist)
                    prompt = strcat("Wrong index, please type again: ",names,"(ctrl+c for exit) ");
                    x1 = input(prompt);
                end
                %%%%%%%% load existed centres %%%%%%%%
                centreOfViews = readmatrix(fullfile(covdir,namelist{x1})); 
                figure;imshow(img,[]);hold on;
                plot(centreOfViews(:,1),centreOfViews(:,2),'.','markersize',20);hold off;
        end
        [~,centreidx] = min(abs(sum(centreOfViews-mean(centreOfViews,1),2)));
        centreOfViews = (centreOfViews-centreOfViews(centreidx,:)) + [size(img,1)/2,size(img,2)/2];
    else % use default simuation
        centreOfViews = [];
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