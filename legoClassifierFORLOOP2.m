%Load the test image. This can be replaced by webcam input
%Test = imread('C:\Users\marti\Desktop\2. semester Control and Automation\Robot Vision\test1.jpg'); 
%%
% Get the robot ip from the teach pendant: File -> About
robot_ip = '192.168.1.80';
% robot_ip = '127.0.0.1';         % URsim
sock = tcpip(robot_ip, 30000, 'NetworkRole', 'server');
fclose(sock);
disp('Press Play on robot');
fopen(sock);
disp('Connected!');
%%
clear cam;
clc;
inipos = [388.2100 -294.2200 271.1200 -1.2848 2.8497 -0.0066];  %Translational measurements in mm
stackpos1 = [250.1900 -451.7200 22.5462 -1.2596 2.8646 -0.0178];
stackposini = stackpos1 + [0 0 100 0 0 0];
immid = [320,240];
pix2mm = 2.0876;
closepix2mm = sqrt(80^2+95^2)/20;
%Duplo brick height = 19.2mm

urMoveL(sock,inipos)
pause(1)
cam = webcam('c922 Pro Stream Webcam');
for i = 1:20
    snapshot(cam);
end
Test = snapshot(cam);
%Test = imread('Workspace+images/testingimage.png');
figure(1)
imshow(Test)

[T, bounds, centroid, class] = getCentroid(Test);

imshow(Test)
title('Classification of Lego Bricks')
hold on
gray = [0.5, 0.5, 0.5];
orange = [1,0.5,0.5];
%plotcentroids;
%%%%%PLOT CENTROIDS
plotBrick(Test, bounds, centroid, class)
homer = [ 3; 4; 1;5;3;4];
for i = 1:length(homer)
    getbrick(homer(i), sock, centroid, (i-1)*19.2,cam);
    [T, bounds, centroid, class] = getCentroid(Test);
    plotBrick(Test, bounds, centroid, class)
end

%60 in z for good position
%z position for brick grip = 5.1437

%% Testing zone:
%Characters
%margeGYB, homerBBlY, bartBRY, lisaOOY, maggieBY
