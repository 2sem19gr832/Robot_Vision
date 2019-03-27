function getbrick(color,sock,centroid,stackheight,cam)
%also include current stackpos or inistackpos?
%Characters %margeGYB, homerBBlY, bartBRY, lisaOOY, maggieBY
%RGBYOBl
%%% CONSTANTS:::
inipos = [388.2100 -294.2200 271.1200 -1.2848 2.8497 -0.0066];  %Translational measurements in mm
stackpos1 = [250.1900 -451.7200 22.5462+stackheight -1.2596 2.8646 -0.0178]; %Necessary position to stack duplo bricks.
stackposini = stackpos1 + [0 0 100 0 0 0];
immid = [320,240];
pix2mm = 2.0876;
closepix2mm = sqrt(80^2+95^2)/20;

%next, pick up brick, increment stackheight by 19.2mm, return.
    target = [centroid{color}{1}(1).Centroid(1),centroid{color}{1}(1).Centroid(2)] - immid;
    target = target / pix2mm;
    movetool(sock,[target,200],[0,0,0])
    pause(0.1)
    for i = 1:2         %run a few times to ensure proper alignment with brick to be picked
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
    gripclose(sock)
    pause(0.2)
    urMoveL(sock,inipos)
    urMoveL(sock,stackposini)
    urMoveL(sock,stackpos1)
    gripopen(sock);
    urMoveL(sock,stackposini)
    urMoveL(sock,inipos)
stackheight2 = stackpos1+[0 0 19.2 0 0 0];