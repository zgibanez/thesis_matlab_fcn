calibration_file = 'calib_1C.tka';

%Parse .txt file
fid  = fopen(calibration_file,'r');
text = textscan(fid,'%s','Delimiter','');
text = text{1};
fid  = fclose(fid);

%Parse focal length
f = regexp(text,'%f[\s]+(\d+[.]\d+)','tokens');
f = [f{:}];
f = str2double(f{1});

%Parse camera centers cx and cy
cx = regexp(text,'%x[\s]+(\d+[.]\d+)','tokens');
cx = [cx{:}];
cx = cx{1};
%cx = str2double(cx{1});

cy = regexp(text,'%y[\s]+(\d+[.]\d+)','tokens');
cy = [cy{:}];
cy = cy{1};
%cy = str2double(cy{1});