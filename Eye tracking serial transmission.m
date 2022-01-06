%% Initialization of variables and serial communication
clc;
clear all;
close all;
delete(instrfind);
% Set up the COM port for serial communication
%-disp('Setting up serial communication...');
% Determine which COM port is for microcontroller and change
%-s = serial('COM4','Parity','none','FlowControl','none','BaudRate',9600);
% Open serial COM port for communication
%-fopen(s);
%-set(s,'Timeout',10);
prev_left = [0 0 0 0];
prev_right = [0 0 0 0];
prev_left_flag=0;
prev_right_flag =0;
prev_flag = 2;
check_left = 0;
check_right = 0;
check_straight_right = 0;
check_straight_left = 0;
check_left_right = 0;
check_right_left = 0;
%% Image Capture and Eye Detection
vid=videoinput('winvideo',1);
start(vid)



while(vid.FramesAcquired<=25)

I = getsnapshot(vid);
I = rgb2gray(I);
I = imadjust(I);
I = adapthisteq(I);
I = imrotate(I,180);
faceDetector = vision.CascadeObjectDetector('LeftEye');
j=0;
left_flag=0;
right_flag=0;
bboxes = step(faceDetector, I);
[m,n] = size(bboxes);
IFaces = insertObjectAnnotation(I, 'rectangle', bboxes, 'Eye');
imshow(IFaces), title('Detected eye');
%% Image Processing
TF = isempty(bboxes);
if (TF==1) disp('nothing');
k=1;
else
k=0;
end

for i=1:1:m



if (bboxes(i,3) < 150)
% display('invalid eye');
elseif (bboxes(i,3) > 300)
% display('invalid eye');
else
j=j+1;
eye(j,:) = bboxes(i,:);
end
end

if (j>0)
for (i=1:1:j)
if(eye(i,1)>300) && (eye(i,1)<600)
left_eye = eye(i,:);
disp('Left:');
disp(left_eye);
left_flag=1;

elseif(eye(i,1)>600) && (eye(i,1)<900)
right_eye = eye(i,:);
disp('Right:');
disp(right_eye);
right_flag=1;
end

end



%% Movement Detection
if((left_flag==1)&& (prev_left_flag ==1))
prev_left_flag = 1;
if((left_eye(1,1) - prev_left(1,1))>50)
flag = 0;
display('moved left');
elseif ((left_eye(1,1) - prev_left(1,1))<-50)
flag = 1;
display('moved right');
else
flag = 2;
display('stayed');
end
prev_left = left_eye;

elseif((right_flag==1)&&(prev_right_flag==1))
prev_right_flag = 1;
if((right_eye(1,1) - prev_right(1,1))>50)
flag = 0;
display('moved left');
elseif ((right_eye(1,1) - prev_right(1,1))<-50)
flag = 1;
display('moved right');
else
flag = 2;
display('stayed');
end
prev_right = right_eye;
elseif(left_flag==1)



prev_left_flag = 1;
if((left_eye(1,1) - prev_left(1,1))>50)
flag = 0;
display('moved left');
elseif ((left_eye(1,1) - prev_left(1,1))<-50)
flag = 1;
display('moved right');
else
flag = 2;
display('stayed');
end
prev_left = left_eye;

elseif(right_flag==1)
prev_right_flag = 1;
if((right_eye(1,1) - prev_right(1,1))>50)
flag = 0;
display('moved left');
elseif ((right_eye(1,1) - prev_right(1,1))<-50)
flag = 1;
display('moved right');
else
flag = 2;
display('stayed');
end
prev_right = right_eye;
end

if (left_flag == 0)
prev_left_flag=0;



elseif (right_flag == 0)
prev_right_flag=0;
end
%% Motor Control Signals
if ((prev_flag == 0) && (flag == 1)) % straight movement
display('motor moved straight');
move = 2;
check_straight_right = 1;
check_left_right = 1;
elseif ((prev_flag ==1) && (flag == 0))
move = 2;
display('motor moved straight');
check_straight_left = 1;
check_right_left = 1;
elseif ((prev_flag == 0) && (flag == 2)) % left movement
if ((check_right == 1) || (check_straight_right == 1)||(check_right_left))
move = 3;
display('motor stays');
check_right = 0;
check_straight_right = 0;
check_right_left = 0;
else
move = 0;
display('motor moved left');
check_left = 1;
end



elseif ((prev_flag == 1) && (flag == 2)) % right movement
if ((check_left == 1) || (check_straight_left == 1) || (check_left_right))
move = 3;
display('motor stays');
check_left = 0;
check_straight_left = 0;
check_left_right = 0;
else
move = 1;
display('motor moved right');
check_right = 1;
end

else % no movement
move = 3;
display('motor stays');
end

prev_flag = flag;
%% Serial Transmission

%-fprintf(s,'%1d\n',move);
%-disp('done');
end
hold on;


end
stop(vid);
flushdata(vid);
pause(0.04);
%-fclose(s);
%_delete(s);
%-clear s;
clear all;