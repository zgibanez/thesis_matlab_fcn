  % Load MRI scan
  load('mri','D'); D=smooth3(squeeze(D));
  % Make iso-surface (Mesh) of skin
  FV=isosurface(D,1);
  % Calculate Iso-Normals of the surface
  N=isonormals(D,FV.vertices);
  L=sqrt(N(:,1).^2+N(:,2).^2+N(:,3).^2)+eps;
  N(:,1)=N(:,1)./L; N(:,2)=N(:,2)./L; N(:,3)=N(:,3)./L;
  % Display the iso-surface
  figure, patch(FV,'facecolor',[1 0 0],'edgecolor','none'); view(3);camlight
  % Invert Face rotation
  FV.faces=[FV.faces(:,3) FV.faces(:,2) FV.faces(:,1)];
