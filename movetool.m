function movetool(sock, lin, rot_deg)


    rad = rot_deg * pi/180;
    Robot_Pose = urReadPosC(sock);
    Translation = Robot_Pose(1:3); % in mm
    Orientation = Robot_Pose(4:6);
    
    rx = rad(1);
    ry = rad(2);
    rz = rad(3);
    Rx = [1 0 0; 0 cos(rx) -sin(rx); 0 sin(rx) cos(rx)];
    Ry = [cos(ry) 0 sin(ry); 0 1 0; -sin(ry) 0 cos(ry)];
    Rz = [cos(rz) -sin(rz) 0; sin(rz) cos(rz) 0; 0 0 1];


    orientation_mat = vrrotvec2mat([Orientation,norm(Orientation)]);
    Rot_z = Rx*Ry*Rz;
    Goal_orient = orientation_mat *Rot_z;
    
    Goal_v = vrrotmat2vec(Goal_orient(1:3,1:3));
    Goal_ori = Goal_v(4)*Goal_v(1:3);

    
    des_trans = Translation + lin*orientation_mat;
    
    urMoveL(sock, des_trans, Goal_ori);
    
    
