clear all
webcamlist;
cam = webcam('c922 Pro Stream Webcam');
preview(cam)
img = snapshot(cam);
imshow(img);