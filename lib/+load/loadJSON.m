function s = loadJSON(filename)
    fname = filename; 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    s   = jsondecode(str);
    mag = (s.f_tube*s.f_u)/(s.f_obj*s.f_fl);
    s.lateral_rate = s.cam_pixsize/mag;
    s.axial_rate = s.lateral_rate;
end