function success = getRegisteredScansFromFolder( rawFolder, processedFolder )
%GETREGISTEREDSCANSFROMFOLDER Summary of this function goes here
%   Input: Folder where there are subfolders of every action
%   Hierachy of files: 
%       Raw -> Subject -> Action -> mesh / texture
%       Processed -> Subject -> actionX.mat

    %Get the folders for the diferent subjects
    directory = dir(rawFolder);
    dirFlags = [ directory.isdir ];
    d = directory(dirFlags);
    subjects=d(~ismember({d.name},{'.','..'}));
    
    for i=1:numel(subjects)
        
        %Get the action folders of the subject
        action_path = strcat(rawFolder,'\',subjects(i).name);
        d = dir(action_path);
        dirFlags = [ d.isdir ];
        d = d(dirFlags);
        actions=d(~ismember({d.name},{'.','..'}));
        
        %Check if output folder exists. If not, create one.
        %FROM: https://stackoverflow.com/questions/22509260/how-to-get-the-name-of-the-parent-folder-of-a-file-specified-by-its-full-path
        output_folder = strcat(processedFolder,'/',subjects(i).name);
         
        if(exist(output_folder,'dir') == 0)
            mkdir(output_folder);
        end
        
        for j=1:numel(actions)
            %Get its action structure
            action_folder = strcat(action_path,'\',actions(j).name);
            out_action_file = strcat(output_folder,'/',actions(j).name,'.csv');
            saveActionFile(action_folder,out_action_file);
        end
        
    end
    
    success = 1;
    
end

function saveActionFile(folder,out_file_name)
    
    %%%%LANDMARK INFORMATION%%%%

    %Check if landmark file exists
    landmark_file = strcat(folder,'/landmarks.csv');
    lnd_file_exists = exist(landmark_file,'file') == 2;
    
    %If it does not exist, extract landmark locations
    if(~lnd_file_exists)
        getLandmarksFromImageSequence(folder);
    end

    %%%MESH INFORMATION%%%
    
    %Collect all the 3D scans
    mesh_folder = strcat(folder,'/mesh');
    object_files = dir(strcat(mesh_folder,'/*.obj'));
    
    %Load preconfigured Options
    Options = load('Options','Options');
    Options = Options.Options;
    
    %Load source (template) mesh)
    Source = load('Source_repaired','Source');
    Source = Source.Source;
    
    %If .csv exists, load list of mesh indexes already processed
    if(exist(out_file_name,'file') ==2)
        processed_meshes = xlsread(out_file_name,'A:A');
    else
        processed_meshes = [];
    end
    
    %For every scan
    for i=1:numel(object_files)

        [~,mesh_name,~] = fileparts(object_files(i).name);
        
        % Get the index of the mesh
        %File format: (ACTION+UNIT_INDEX)
        %Texture format: (texture_AU_INDEX)
        f = regexp(mesh_name,'_','split');
        frame_idx = str2double(f{2}); %returns INDEX
       
        %Check if this mesh has been processed
        if (any(processed_meshes == frame_idx))
            continue
        end
        
        %Apply nonrigid ICP and store the vertex values
        mesh_path = strcat(mesh_folder,'/',object_files(i).name);
        vertices = nonrigidICP(Source,Options,mesh_path);
        
        %Write an object to test results
%         OBJ.v = vertices;
%         OBJ.vn = [];
%         OBJ.f.v = Source.faces;
%         writeObject(OBJ,'result.obj');
        
        vertices = [frame_idx, reshape(vertices,1,[])];
        dlmwrite(out_file_name,vertices,'delimiter',',','-append');
        fprintf('Frame %d of mesh %s saved in %s.',frame_idx,object_files(i).name,out_file_name);
   end

end

%Applies non rigid registration of Source towards an .OBJ file
function vertices = nonrigidICP(Source, Options, target_file)

    %Read target obj
    tempTarget = readObj(target_file);
    
    %Simple smooth to get rid of the noise
    [v,f] = smoothMesh(tempTarget.vertices,tempTarget.faces,1);
    Target.vertices = v;
    Target.faces = f;
    Target.normals = [];
    
    %Apply non-rigid ICP to smoothed mesh
    [~,name,ext] = fileparts(target_file);
    disp(strcat('Applying non-rigid ICP to file: ',name, ext, '...'));
    [vertices, ~] = nricp(Source,Target,Options);
    disp('Registration Complete.');
    
end


function getLandmarksFromImageSequence(folder)

    image_folder = strcat(folder,'\texture_1C');
    %exe_path = 'D:\OpenFace\OpenFace\x64\Release';
    %cd(exe_path);
    
    %Get calibration parameters
    calibration_folder = strcat(folder,'\calib\');
    calibration_file = strcat(calibration_folder, 'calib_1C.tka');
    params = readCalibrationFile(calibration_file);
    is_calibration_missing = any( structfun(@isempty, params));
    
    % The location executable will depend on the OS
    if(isunix)
        executable = '"../../build/bin/FeatureExtraction"';
    else
        %executable = '"../../x64/Release/FeatureExtraction.exe"';
        executable = '"feature_extraction/FeatureExtraction.exe"';
    end
    
    % Write the complete command and execute it
    % from: https://github.com/TadasBaltrusaitis/OpenFace/wiki/Command-line-arguments
    % NOTE: flag -of can be used
    if(is_calibration_missing)
        command = sprintf('%s -fdir "%s" -out_dir "%s" -verbose -3Dfp -pose -pdmparams -q -of landmarks', executable, image_folder, folder);
    else
        command = sprintf('%s -fdir "%s" -out_dir "%s" -verbose -3Dfp -pose -pdmparams -q -fx %f -fy %f -of landmarks', executable, image_folder, folder, params.f*params.xsize/(params.sx*params.xsize), params.f*params.ysize/(params.sy*params.ysize));
    end
    if(isunix)
        unix(command);
    else
        dos(command);
    end
    
end

% Parse txt calibration file to obtain focal length and center
% https://nl.mathworks.com/matlabcentral/answers/13585-find-the-key-word-in-the-text-file-then-pick-the-value-next-to-it
function params = readCalibrationFile(calibration_file)

    %Parse .txt file
    fid  = fopen(calibration_file,'r');
    if(fid == -1)
        error('Error: Cannot open calibration file.');
    end
    text = textscan(fid,'%s','Delimiter','');
    text = text{1};
    fid  = fclose(fid);
    if(fid == -1)
       error('Error at closing calibration file');
    end
    %Parse focal length
    f = regexp(text,'%f[\s]+(\d+[.]\d+)','tokens');
    f = [f{:}];
    f = str2double(f{1}{1});

    %Parse pixel size (in mm)
    sx = regexp(text,'%x[\s]+(\d+[.]\d+)','tokens');
    sx = [sx{:}];
    sx = str2double(sx{1}{1});
    %cx = cx{1}{1};
    
    sy = regexp(text,'%y[\s](\d+[.]\d+)','tokens');
    sy = [sy{:}];
    sy = str2double(sy{1}{1});
    %cy = cy{1}{1};
    
    %Parse sensor size
    ssize = regexp(text,'%is[\s](\d+)[\s](\d+)','tokens'); ssize = [ssize{:}];
    %ssize = regexp(text,'%is[\s]+(\d+[.]\d+)[\s]+(\d+[.]\d+)','tokens'); 
    
    params.f = f;
    params.sx = sx;
    params.sy = sy;
    params.xsize = str2double(ssize{1}{1});
    params.ysize = str2double(ssize{1}{2});
    
end