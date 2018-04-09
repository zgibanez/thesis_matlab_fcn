function [ Rx, Ry, Rz, T ] = GetRotationMatrix( headP )

    yaw = headP(3);
    pitch = headP(2);
    roll = headP(1);
    
    xc = headP(4);
    yc = headP(5);
    zc = headP(6);

    T = [1, 0, 0, xc; 
        0, 1, 0, yc; 
        0, 0, 1, zc; 
        0, 0, 0, 1];
    
    Rz = [ cos(yaw), -sin(yaw), 0, 0; 
           sin(yaw), cos(yaw), 0, 0;
           0, 0, 1, 0; 
           0, 0, 0, 1];
       
    Ry = [cos(pitch), 0, sin(pitch), 0; 
          0, 1, 0, 0;
          -sin(pitch), 0, cos(pitch), 0;
          0, 0, 0, 1];
      
    Rx = [1, 0, 0, 0; 
        0, cos(roll), -sin(roll), 0;
        0, sin(roll), cos(roll), 0;
        0, 0, 0, 1];

end

