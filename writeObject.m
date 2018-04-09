
function writeObject(obj,filename)

% if(isempty(obj.f.vn))
%    obj.f.vn = isonormals(D,FV.vertices);
% end

if(~isfield(obj,'vn'))
    obj.vn = [];
end

%Define material
material(1).type='newmtl';
material(1).data='skin';
material(2).type='Ka';
material(2).data=[0.8 0.4 0.4];
material(3).type='Kd';
material(3).data=[0.8 0.4 0.4];
material(4).type='Ks';
material(4).data=[1 1 1];
material(5).type='illum';
material(5).data=2;
material(6).type='Ns';
material(6).data=27;

%Define obj variables
OBJ.vertices = obj.v;
OBJ.vertices_normal = obj.vn;
OBJ.material = material;
OBJ.objects(1).type='g';
OBJ.objects(1).data='skin';
OBJ.objects(2).type='usemtl';
OBJ.objects(2).data='skin';
OBJ.objects(3).type='f';
OBJ.objects(3).data.vertices=obj.f.v;
OBJ.objects(3).data.normal=obj.f.v;

write_wobj(OBJ,filename);

end