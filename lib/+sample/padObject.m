function object = padObject(object,dim)
    objectsz = size(object);

    m = floor((dim(1)-objectsz(1))/2); n = floor((dim(2)-objectsz(2))/2); z = floor((dim(3)-objectsz(3))/2);
    object = padarray(object,[m,n,z],'both'); 
    if(size(object,1) ~= dim(1)); object = padarray(object,[1 0 0],'post'); end
    if(size(object,2) ~= dim(2)); object = padarray(object,[0 1 0],'post'); end
    if(size(object,3) ~= dim(3)); object = padarray(object,[0 0 1],'post'); end
end