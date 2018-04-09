
% [file, path] = uigetfile('\*.csv');
% output_csv = strcat(path,file);
output_csv = 'C:\Users\pey_l\Desktop\nonrigidICP\landmarks.csv';

% First read in the column names, to know which columns to read for
% particular features
tab = readtable(output_csv);
column_names = tab.Properties.VariableNames;

% Read all of the data
all_params  = dlmread(output_csv, ',', 1, 0);

% This indicates which frames were succesfully tracked

% Find which column contains success of tracking data and timestamp data
valid_ind = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'success'));
time_stamp_ind = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'timestamp'));

% Extract tracking success data and only read those frame
valid_frames = logical(all_params(:,valid_ind));

% Get the timestamp data
time_stamps = all_params(valid_frames, time_stamp_ind);


%% Demonstrate 3D landmarks
landmark_inds_x = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'X_'));
landmark_inds_y = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'Y_'));
landmark_inds_z = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'Z_'));

xs = all_params(valid_frames, landmark_inds_x);
ys = all_params(valid_frames, landmark_inds_y);
zs = all_params(valid_frames, landmark_inds_z);

%Head pose
head_tx_inds = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'pose_Tx'));
head_ty_inds = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'pose_Ty'));
head_tz_inds = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'pose_Tz'));

head_tx = all_params(valid_frames, head_tx_inds);
head_ty = all_params(valid_frames, head_ty_inds);
head_tz = all_params(valid_frames, head_tz_inds);

%Head orientation
head_rx_inds = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'pose_Rx'));
head_ry_inds = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'pose_Ry'));
head_rz_inds = cellfun(@(x) ~isempty(x) && x==1, strfind(column_names, 'pose_Rz'));

head_rx = all_params(valid_frames, head_rx_inds);
head_ry = all_params(valid_frames, head_ry_inds);
head_rz = all_params(valid_frames, head_rz_inds);

%Allign face with origin
nframes = size(head_tx,1);
nlandmarks = 68;
xs_r = zeros(nframes,nlandmarks);
ys_r = zeros(nframes,nlandmarks);
zs_r = zeros(nframes,nlandmarks);

for frame=1:nframes
    pose_params = [head_rx(frame) head_ry(frame) head_rz(frame) head_tx(frame) head_ty(frame) head_tz(frame)];
    [Rx, Ry, Rz, T] = GetRotationMatrix(pose_params);
    
    for landmark=1:nlandmarks
        %Remove translation
        point = [xs(frame,landmark) ys(frame,landmark) zs(frame,landmark)]';
        point = point-T(1:3,4);
        point = [point; 1]
        
        %Rotate until face is alligned with axis
        rotated_point = inv(Rz)*inv(Ry)*inv(Rx)*point;
        xs_r(frame,landmark) = rotated_point(1);
        ys_r(frame,landmark) = rotated_point(2);
        zs_r(frame,landmark) = rotated_point(3);
    end
end

figure
for j = 1:size(xs,1)
    plot3(xs_r(j,:), ys_r(j,:), zs_r(j,:), '.');

    %axis equal;
    hold off;
    xlabel('X (mm)');
    ylabel('Y (mm)');    
    zlabel('Z (mm)');    
    drawnow
    pause(0.2);
end