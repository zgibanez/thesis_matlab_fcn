function compareMeshCorrespondence(OBJ1,~)

    nFaces = size(OBJ1.faces,1);
    nVertices = size(OBJ1.vertices,1);
    interp = linspace(0,1,nFaces);
    interpi = fliplr(interp);
    colorInterpolation = [interp; interp; interp]';
    %colorInterpolation = [0 1 1];
    patch('Faces',OBJ1.faces,'Vertices',OBJ1.vertices,'FaceVertexCData',colorInterpolation,'FaceColor','flat');
    %fill3(OBJ1.vertices
    axis equal;
end