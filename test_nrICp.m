[file, path] = uigetfile('*.obj');

Target = readObj(strcat(path,file));

vertsTarget = Target.vertices;
vertsSource = Source.vertices;
nVertsSource = size(Source.vertices,1);

sourceCenter = sum(Source.vertices)/size(Source.vertices,1);
targetCenter = sum(Target.vertices)/size(Target.vertices,1);

TempSource = Source;
TempSource.vertices = Source.vertices + repmat((targetCenter-sourceCenter),nVertsSource,1);

% % Set matrix D (equation (8) in Amberg et al.)
% D = sparse(nVertsSource, 4 * nVertsSource);
% for i = 1:nVertsSource
%     D(i,(4 * i-3):(4 * i)) = [vertsSource(i,:) 1];
% end

%Load default Options
load Options;

% Set default parameters
% if ~isfield(Options, 'gamm')
%     Options.gamm = 1;
% end
% if ~isfield(Options, 'epsilon')
%     Options.epsilon = 1e-4;
% end
% if ~isfield(Options, 'lambda')
%     Options.lambda = 1;
% end
% if ~isfield(Options, 'alphaSet')
%     Options.alphaSet = linspace(100, 10, 10);
% end
% if ~isfield(Options, 'biDirectional')
%     Options.biDirectional = 0;
% end
% if ~isfield(Options, 'useNormals')
%     Options.useNormals = 0;
% end
% if ~isfield(Options, 'plot')
%     Options.plot = 0;
% end
% if ~isfield(Options, 'rigidInit')
%     Options.rigidInit = 1;
% end
% if ~isfield(Options, 'ignoreBoundary')
%     Options.ignoreBoundary = 1;
% end
% if ~isfield(Options, 'normalWeighting')
%     Options.normalWeighting = 1;
% end

% Optionally plot source and target surfaces
% if Options.plot == 1
%     clf;
%     PlotTarget = rmfield(Target, 'normals');
%     p = patch(PlotTarget, 'facecolor', 'b', 'EdgeColor',  'none', ...
%               'FaceAlpha', 0.5);
%     hold on;
%     
%     PlotSource = rmfield(Source, 'normals');
%     h = patch(PlotSource, 'facecolor', 'r', 'EdgeColor',  'none', ...
%         'FaceAlpha', 0.5);
%     material dull; light; grid on; xlabel('x'); ylabel('y'); zlabel('z');
%     view([60,30]); axis equal; axis manual;
%     legend('Target', 'Source', 'Location', 'best')
%     drawnow;
% end

% % Get boundary vertex indices on target surface if required.
% if Options.ignoreBoundary == 1
%     bdr = find_bound(vertsTarget, Target.faces);
% end
% 
% disp('* Performing rigid ICP...');
%     if Options.ignoreBoundary == 0
%         bdr = 0;
%     end
%     [R, t] = icp(vertsTarget', vertsSource', 50, 'Verbose', true, ...
%                  'EdgeRejection', logical(Options.ignoreBoundary), ...
%                  'Boundary', bdr');
%     X = repmat([R'; t'], nVertsSource, 1);
%     vertsTransformed = D*X;
%     
%     % Update plot
%     if Options.plot == 1
%         set(h, 'Vertices', vertsTransformed);
%         drawnow;
%     end
%     
    
%[registered,targetV,targetF]=nonrigidICP(Target.vertices,vertsTransformed,Target.faces,Source.faces,10,1)
[registered, ~] = nricp(TempSource,Target,Options);

OBJ.v = registered;
OBJ.vn = [];
OBJ.f.v = Source.faces;
writeObject(OBJ,strcat(path,file,'_result.obj'));


