% save the reconstruction to the specific directory
function resultFilename = saveResultVol(resultdir,resultVol,resultFilename,r,c)
% input  : resultdir, FOLDER directory for saving result
%          resultVol, the reconstructed 3d volume
%          resultFilename, the filename (no directory) for saving the reconstructed 3d volume. If this is empty, the default name will be used (i.e., resultVol_x.tif)
%          r, the specific range in row for result volume cropping 
%          c, the specific range in column for result volume cropping 
% output : resultFilename, the FULL directory for the saved results. might be useful to load results in the future
    if nargin < 4
        r = [];
        c = [];
        vol = resultVol;
    else
        % r = [400 600];
        % c = [400 600];
        vol = resultVol(r(1):r(2),c(1):c(2),:);
    end

    resultdir1 = fullfile(load.makeDir(resultdir),'*.tif');
    namelist   = {dir(resultdir1).name}';
    
    if isempty(resultFilename) % no name specified, default name is used
        resultFilename = ['resultVol_',num2str(length(namelist)+1),'.tif']; 
    else % name is specified by the user
        [~,name,ext] = fileparts(resultFilename);
        if ~strcmp(ext,'.tif') %no or wrong file extension specified
            resultFilename = [name,'.tif'];
        end
    end
    resultFilename = fullfile(resultdir,resultFilename);
    load.Tifwrite(vol,resultFilename)
end