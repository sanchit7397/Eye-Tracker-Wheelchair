clear all   
clf('reset');



cam = webcam();
global a
a=arduino('COM3','Uno','Libraries','')

runLoop = true;
detector1 = vision.CascadeObjectDetector('EyePairBig');
right=imread('RIGHT.jpg');
left=imread('LEFT.jpg');
noface=imread('no_face.jpg');
straight=imread('STRAIGHT.jpg');

while runLoop

    
    videoFrame = snapshot(cam);
    img = flip(videoFrame, 2);
    
    vid = rgb2gray(img);
    vid = imadjust(vid);
    vid = adapthisteq(vid);
    
    bboxeyes = step(detector1, vid);
    
    if ~ isempty(bboxeyes) 
             
             biggest_box_eyes=1;     
                        
             bboxeyeshalf=[bboxeyes(biggest_box_eyes,1),bboxeyes(biggest_box_eyes,2),bboxeyes(biggest_box_eyes,3)/2,bboxeyes(biggest_box_eyes,4)];   %resize the eyepair width in half
             
             eyesImage = imcrop(vid,bboxeyeshalf(1,:));
             eyesImage = imadjust(eyesImage);
             
                     
             r = bboxeyeshalf(1,4)/5;
             [centers, radii] = imfindcircles(eyesImage, [floor(r-r/4) floor(r+r/2)], 'ObjectPolarity','dark', 'Sensitivity', 0.93); % Hough Transform
             
                 
             eyesPositions = centers;
                 
             subplot(2,1,1),imshow(eyesImage);
             hold on;
              
             viscircles(centers, radii,'EdgeColor','y');
                  
             if ~isempty(centers)
                pupil_x=centers(1);
                disL=abs(0-pupil_x);
                disR=abs(bboxeyes(1,3)/3-pupil_x);
                subplot(2,1,2);
                if disL>disR+20
                    imshow(right);
                    
                    writeDigitalPin(a, 'D5', 0);
                    writeDigitalPin(a, 'D6', 1);
                    writeDigitalPin(a, 'D9', 1);
                    writeDigitalPin(a, 'D10', 0);
                    
                                       
                else
                    if disR+10>disL
                    imshow(left);
                    
                    writeDigitalPin(a, 'D5', 1);
                    writeDigitalPin(a, 'D6', 0);
                    writeDigitalPin(a, 'D9', 0);
                    writeDigitalPin(a, 'D10', 1);
                    
                    
                    else
                       imshow(straight); 
                       
                    writeDigitalPin(a, 'D5', 0);
                    writeDigitalPin(a, 'D6', 1);
                    writeDigitalPin(a, 'D9', 0);
                    writeDigitalPin(a, 'D10', 1);
                    
                    end
                end
     
             end          
    else
        subplot(2,1,2);
        imshow(noface);
        
        writeDigitalPin(a, 'D5', 0);
        writeDigitalPin(a, 'D6', 0);
        writeDigitalPin(a, 'D9', 0);
        writeDigitalPin(a, 'D10', 0);
     end
    
    
    
       
end


clear cam;
