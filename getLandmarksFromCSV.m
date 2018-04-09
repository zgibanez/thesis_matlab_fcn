close all;
clear all;
%[file,path] = uigetfile('*.csv');
file = 'C:\Users\pey_l\Desktop\nonrigidICP\landmarks.csv';
%fid = fopen(strcat(path,file));
fid = fopen(file);
data = textscan(fid,[repmat('%f', 1, 254) '%*[^\n]'], -1, 'delimiter', ',', 'HeaderLines', 1, 'collectoutput', true);
data = cell2mat(data);
headT = data(:,5:7);
headR = data(:,8:10);
landmarks3D = data(:,11:214);
landmarks3D = reshape(landmarks3D,[],3);
fclose(fid);

[row,col] = size(landmarks3D);

%Frames = rows/#landmarks
frames = row/68-1;

figure();
% axis_limits = [min(landmarks3D(:,1)) max(landmarks3D(:,1)) min(landmarks3D(:,2)) max(landmarks3D(:,2)) min(landmarks3D(:,3)) max(landmarks3D(:,3))];
% axis(axis_limits);
axis equal;
for i=0:frames
    
    landmarks_frame = landmarks3D((i*68)+1:(i*68)+68,:);
    scatter3(landmarks_frame(:,1),landmarks_frame(:,2),landmarks_frame(:,3));
    pause(0.1);
    
end