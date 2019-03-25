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
inipos = [388.2100 -294.2200  271.1200   -1.2848    2.8497   -0.0066];  %Translational measurements in mm
stackpos1 = [250.1900 -451.7200   22.5462   -1.2596    2.8646   -0.0178];
stackposini = stackpos1 + [0 0 100 0 0 0];
%Duplo brick height = 19.2mm
urMoveL(sock,inipos)
pause(0.1)
cam = webcam('c922 Pro Stream Webcam');
for i = 1:20
    snapshot(cam);
end
Test = snapshot(cam);
figure(1)
imshow(Test)
%Each color channel of the image, these can later be used.
R = Test(:, :, 1);
G = Test(:, :, 2);
B = Test(:, :, 3);
immid = [320,240];
pix2mm = 2.0876;
closepix2mm = sqrt(80^2+95^2)/20;

classes = zeros(length(Test(:,1,1)), length(Test(1,:,1)));

for ii=1:size(Test,1) %Inspect each pixel of the image
    for jj=1:size(Test,2)
        % These ratios are used to identify what color each lego brick is.
        % This disregards brightness in the image and can therefore
        % reliably find the lego bricks.
        ratioRB = double(Test(ii,jj,1)+1)/double(Test(ii,jj,3)+1); %Ratio between the Red and blue color.
        ratioBG = double(Test(ii,jj,3)+1)/double(Test(ii,jj,2)+1); %Ratio between the Green and blue color.
        ratioGB = double(Test(ii,jj,2)+1)/double(Test(ii,jj,3)+1); %Ratio between the blue and green color. 
        ratioRG = double(Test(ii,jj,1)+1)/double(Test(ii,jj,2)+1);
        pixel = Test(ii, jj);
          % check pixel value and assign new value
          if ratioRG > 10 && ratioRB > 2 && R(ii, jj) < 150 %RED            RED: ratioBG > 1 && ratioRB > 2
              new_pixel=cat(3, 255, 0, 0);
              classc = 1;
          elseif ratioGB > 1.5 && ratioRG < 1.5 && G(ii, jj) < 100%GREEN      Green: 0.9 > ratioGB && ratioRB < 1
              new_pixel = cat(3, 0, 255, 0);
              classc = 2;
          elseif ratioBG > 1.3 && ratioRB < 0.5 && B(ii,jj) > 50 %BLUE         BLUE: ratioBG > 0.5 && ratioRB < 2
              new_pixel = cat(3, 0, 0, 255);
              classc = 3;
          elseif ratioRG > 1.3 && ratioRB > 2 && G(ii, jj) > 85 %YELLOW       %YELLOW: ratioBG < 1 && ratioRB > 2
              new_pixel = cat(3, 0, 60, 210);
              classc = 4;
          elseif ratioRB > 1.5 && ratioBG < 1.5 && R(ii, jj) > 160 %Orange
              new_pixel = cat(3,60,60,210);
              classc = 5;
          elseif R(ii,jj) < 30 && G(ii,jj) < 30 && B(ii,jj) < 30
              new_pixel = cat(3,0,0,0);
              classc = 6;
          else
              new_pixel = cat(3, 0, 0, 0);
              classc = 0;
          end
          % save new pixel value in thresholded image
          image_thresholded(ii,jj,:)=new_pixel;
          classes(ii, jj) = classc;
          %ratioBGv(ii, jj) = ratioBG;
     end
end
  %Use isMember to make binary images for each color and find the bounding
  %boxes for the lego bricks and the center point.
%level = 0.99; %Used with the imbinarize() function.
%binary2 = imbinarize(image_thresholded, level); %The image has been thresholded, but this changes the 0 and 256 -> 0 and 1


%Make binary images for each class
R = ismember(classes, 1); %RED
G = ismember(classes, 2); %GREEN
B = ismember(classes, 3); %BLUE
Y = ismember(classes, 4); %YELLOW
O = ismember(classes, 5); %ORANGE

class = cat(3, ismember(classes, 1), ismember(classes, 2), ismember(classes, 3), ismember(classes, 4), ismember(classes, 5), ismember(classes, 6));

SE = strel('square',5); %Structuring element of the dialation
SE2 = strel('square',7); %Structuring element of the erosion

for k = 1:length(class(1,1,:))
    J(:, :, k) = imdilate(class(:, :, k), SE); %First dilate and then erode the image.
    T(:, :, k) = imerode(J(:, :, k), SE2); %Filter the image such that most of the noise is removed
    CC(k) = bwconncomp(T(:, :, k), 8);
    S = regionprops(CC(k), 'Area');
    L(:, :, k) = labelmatrix(CC(k));
    BW2(:, :, k) = ismember(L(:, :, k), find([S.Area] >= 300)); %Find the BLOBs larger than 50 pixels and use these as the lego bricks
end

for k = 1:length(class(1,1,:)) %Find boundaries and centroids
    bounds{k} = bwboundaries(BW2(:, :, k), 'noholes');
    
    region{k} = regionprops(BW2(:, :, k),'centroid');
    
    centroid{k} = cat(1, region(k));
end

%figure(1)
%subplot(1, 3, 1)
%imshow(Test)
%title('Original')
%subplot(1, 3, 2)
%imshow(BW2(:, :, 4)+BW2(:, :, 1)+BW2(:, :, 2)+BW2(:, :, 3))
%title('Thresholded by color ratio')
%subplot(1, 3, 3)
imshow(Test)
title('Classification of Lego Bricks')
hold on
gray = [0.5, 0.5, 0.5];
orange = [1,0.5,0.5];

for k = 1:length(class(1,1,:))
    A = cat(1, bounds{k});
    for x = 1:length(bounds{k})
        bounder = cell2mat(A(x));
        centroidd = cell2mat(centroid{k});
        for u = 1:length(centroidd)
            centroids(:,:,u) = struct2array(centroidd(u));
            mid2cent(:,:,u) = centroids(:,:,u)-immid;%[1,1]-immid;%
            m2cmm(:,:,u) = mid2cent(:,:,u)/pix2mm;  %mid to brick center in mm
            if k == 1
                plot(bounder(:,2), bounder(:,1), 'r', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on
                text(centroids(:,1),centroids(:,2), 'RED', 'FontSize', 14, 'color', 'r')
                
            end
            if k == 2
                plot(bounder(:,2), bounder(:,1), 'g', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on
                text(centroids(:,1),centroids(:,2), 'GREEN', 'FontSize', 14, 'color', 'g')
                
            end
            if k == 3
                plot(bounder(:,2), bounder(:,1), 'b', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'BLUE', 'FontSize', 14, 'color', 'b')
                
            end
            if k == 4
                plot(bounder(:,2), bounder(:,1), 'y', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'YELLOW', 'FontSize', 14, 'color', 'y')
                
            end
            if k == 5
                plot(bounder(:,2), bounder(:,1),'Color',[0.9,0.5,0.2], 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'o')
                hold on 
                text(centroids(:,1),centroids(:,2), 'ORANGE', 'FontSize', 10, 'Color', [0.9,0.5,0.2])
                
            end
            if k == 6
                plot(bounder(:,2), bounder(:,1), 'Color',[0.6,0.6,0.6], 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'BLACK', 'FontSize', 10, 'Color', [0.3,0.3,0.3])
                %create array of brick centroids & boundaries.
            end
        end
    end
end
%get centroids of all the possible bricks, using camera calibration get
%distance to said centroid, move over centroid, take another picture, get
%orientation and position of brick irt. tool. -> move down, pick it up.
%Camera calibration for distance, find center of image (center of camera
%axis), then find the center of the rotation (tool rotation axis).

%Movement to centroid
%rot135 = [cosd(135) -sind(135); sind(135) cosd(135)];
%brickpos = (m2cmm(:,:,2)*rot135)*[0 -1;-1 0];
%finalbrickpos = inipos+[brickpos,-200,0,0,0];

% Move to specific brick
target = [centroid{4}{1}(1).Centroid(1),centroid{4}{1}(1).Centroid(2)] - immid;
target = target / pix2mm;
movetool(sock,[target,200],[0,0,0])
pause(0.1)
for i = 1:2
    
    figure(2)
    cu = snapshot(cam);
    hsv = rgb2hsv(cu);
    cubw = imbinarize(hsv(:,:,2), 0.65);
    cuopen = imopen(cubw, strel('disk',2));
    cuCC = bwconncomp(cuopen);
    cuBW2 = bwselect(cuopen, 320,240, 4);
    %max(cell2mat(closeupCC.PixelIdxList))
    %[~, num] = max()
    [brickpos,brickang] = hogorientation(cuBW2);
    %movetool(sock,[0,0,0],[0,0,0])
    %pause(0.1)
    movetool(sock,[brickpos/closepix2mm*-1,0],[0,0,-mod(brickang+45,90)+45])
    pause(0.5)
    figure(4)
    testyimg = snapshot(cam);
    imshow(testyimg)
    hold on
    plot(immid(1),immid(2), '*r')
end
movetool(sock,[0,-41,0],[0,0,0])
movetool(sock,[0,0,65],[0,0,0])
urSetIO(sock,0,1);
urSetIO(sock,1,0);
pause(0.2)
urMoveL(sock,inipos)
urMoveL(sock,stackposini)
urMoveL(sock,stackpos1)
opengrip(sock);
urMoveL(sock,stackposini)
%::::::::::::::::::::::::::::::::::::
%position 2 :::::::::::::::::::::::::
%::::::::::::::::::::::::::::::::::::
target = [centroid{4}{1}(1).Centroid(1),centroid{4}{1}(1).Centroid(2)] - immid;
target = target / pix2mm;
movetool(sock,[target,200],[0,0,0])
pause(0.1)
for i = 1:2
    
    figure(2)
    cu = snapshot(cam);
    hsv = rgb2hsv(cu);
    cubw = imbinarize(hsv(:,:,2), 0.65);
    cuopen = imopen(cubw, strel('disk',2));
    cuCC = bwconncomp(cuopen);
    cuBW2 = bwselect(cuopen, 320,240, 4);
    %max(cell2mat(closeupCC.PixelIdxList))
    %[~, num] = max()
    [brickpos,brickang] = hogorientation(cuBW2);
    %movetool(sock,[0,0,0],[0,0,0])
    %pause(0.1)
    movetool(sock,[brickpos/closepix2mm*-1,0],[0,0,-mod(brickang+45,90)+45])
    pause(0.5)
    figure(4)
    testyimg = snapshot(cam);
    imshow(testyimg)
    hold on
    plot(immid(1),immid(2), '*r')
end
movetool(sock,[0,-41,0],[0,0,0])
movetool(sock,[0,0,65],[0,0,0])
urSetIO(sock,0,1);
urSetIO(sock,1,0);
pause(0.2)
urMoveL(sock,inipos)
urMoveL(sock,stackposini)
urMoveL(sock,stackpos1)
opengrip(sock);
urMoveL(sock,stackposini)

%60 in z for good position
%z position for brick grip = 5.1437
%% close grip:
function closegrip(sock)
urSetIO(sock, 0, 1);
urSetIO(sock, 1, 0);
end
%% open grip:
function opengrip(sock)
urSetIO(sock, 0, 0);
urSetIO(sock, 1, 1);
end
%urMoveL(sock,finalbrickpos);
%urMoveRot(sock,false,[0,0,1], -90)

%% Testing zone:
%bpos = urReadPosJ(sock);

%Characters
%margeGYB, homerBBlY, bartBRY, lisaOOY, maggieBY

Initpos
Function with initpos, image of bricks.
pick bricks BRY
Function to pick brick B (green,bottom pos, 1st char)
Function to place brick B (include some increment thing)

Pick Brick function