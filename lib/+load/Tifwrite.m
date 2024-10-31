function [] = Tifwrite(volume,filename)

    t = Tiff(filename,'w'); % set up tif for writing
    tagstruct.ImageLength = size(volume,1); % image height
    tagstruct.ImageWidth  = size(volume,2); % image width
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software = 'MATLAB';

    % http://www.awaresystems.be/imaging/tiff/tifftags/sampleformat.html
    switch class(volume)
        % Unsupported Matlab data type: char, logical, cell, struct, function_handle, class.
        case {'uint8', 'uint16', 'uint32'}
            tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
        case {'int8', 'int16', 'int32'}
            tagstruct.SampleFormat = Tiff.SampleFormat.Int;
            if options.color
                errcode = 4; assert(false);
            end
        case {'uint64', 'int64'}
            tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
            datatype = double(datatype);
        case {'single', 'double'}
            tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
        otherwise
            % (Unsupported)Void, ComplexInt, ComplexIEEEFP
            errcode = 5; assert(false);
    end

    % Bits per sample
    % http://www.awaresystems.be/imaging/tiff/tifftags/bitspersample.html
    switch class(volume)
        case {'uint8', 'int8'}
            tagstruct.BitsPerSample = 8;
        case {'uint16', 'int16'}
            tagstruct.BitsPerSample = 16;
        case {'uint32', 'int32'}
            tagstruct.BitsPerSample = 32;
        case {'single'}
            tagstruct.BitsPerSample = 32;
        case {'double', 'uint64', 'int64'}
            tagstruct.BitsPerSample = 64;
        otherwise
            errcode = 5; assert(false);
    end


    setTag(t,tagstruct)

    for ii = 1:size(volume,3)
        setTag(t,tagstruct);
        write(t,volume(:,:,ii));
        writeDirectory(t);
    end
    close(t)
end