function start_frame_timestamp=video_cropping_time(video_file,start_time_u,start_frame_minute_u,stop_time_u,stop_frame_minute_u,L_user)

start_time_user = str2double(start_time_u)+(60*str2double(start_frame_minute_u))
stop_time_user = str2double(stop_time_u)+(60*str2double(stop_frame_minute_u))
L = str2double(L_user);

[filepath,name,ext] = fileparts(video_file)
%change path to specified or selected video file (maybe to rename and save
%file there)
cd (filepath)

%to change all spaces with _ in filename
%then
oldFilename=name;
newFilename = strrep(oldFilename,'   ','___');
newFilename = strrep(oldFilename,'  ','__'); 
newFilename = strrep(oldFilename,' ','_'); 

oldFilename=strcat(oldFilename,ext);
newFilename=strcat(newFilename,ext)
tf= (strcmp(oldFilename,newFilename))
if(tf==0)
    movefile(oldFilename, newFilename,'f');  %to rename newfilename
else
    newFilename=oldFilename;
end

input_video=newFilename; 
transcoded_segment_of_input_video='time_cropped_video.avi';    %declare time cropped video
final_segment_of_input_video='final_video.avi';     %declare final_video.avi
fps=30.0  % desired constant frame per second rate (CFR)
cd (filepath)

obj=VideoReader(input_video);

%To get start frame time stamp speciied by user from whole of the video (before taking 100 frames before & after the start,stop frames)

start_frame_timestamp= start_time_user;
 
obj.Duration;
%change the start frame to capture 100 frames before and after the strat,
%stop frames specified by the user
start_time = max (start_time_user - ((L-1)/(2*fps)), 0)
stop_time = min ((stop_time_user + ((L-1)/(2*fps))), obj.Duration)

%stop_time=max(stop_time,start_time);

%put the file path(after 'cd ') where HnadbrakeeCLI.exe is located \\ the
%videos should also be located/copied to the same path
s=sprintf('cd %s',filepath);
system(s);
%delete the previous version of cropped video
s=sprintf('del "%s"',transcoded_segment_of_input_video);
%delete the previous version of final video as well

s=sprintf('del "%s"',final_segment_of_input_video);
system(s);    

%handbrake for vropping video
s=sprintf('HandBrakeCLI.exe -i %s --start-at duration:%d  --stop-at duration:%d -e x264 --encoder-preset veryfast -q 10 --cfr -r %d -o %s', input_video, start_time, stop_time-start_time, fps,transcoded_segment_of_input_video);
system(s);

obj=VideoReader(transcoded_segment_of_input_video);
display(['total frames: time cropped video : ' num2str(obj.NumberOfFrames)]); 
display(['total time: time cropped video : ' num2str(obj.Duration)]); 

for k=1:obj.NumberOfFrames
 mov(k).cdata = read(obj, k);
end

%write each frame from mov array into video with start stop frames
%specified

%point to the start frame of transcoded(time-cropped)video for image cropping tool to work
k=1;
I=mov(k).cdata;
imshow(I);

%vidObj_crop = VideoWriter(final_segment_of_input_video);
%open(vidObj_crop);

% Give the user to make the rectangle on the image to Crop image starting 
%[J, rect] = imcrop(I);
%h=imfreehand(I)
%BW = createMask(h) returns a mask, or binary image, that is the same size as the input image with 1s inside the ROI object h and 0s everywhere else. The input image must be contained within the same axes as the ROI.

%Apply the same rectangle to rest of the frames of the whole video 
%for k=1:obj.NumberOfFrames   %it reads one frame more
 % I = read(obj, k);
 % cropped_img = imcrop(I, rect);
%  face_cropped_img=detect_face(cropped_img);   %take the cropped face image from function as to extract pixel avg value from only face region

 % writeVideo(vidObj_crop,cropped_img);
  
  %write the masked image into final video
  %color mask code - this gives output as a binary mask BW and a composite image cropped_masked_img,
%  which shows the original RGB image values under the mask BW
%  [BW_mask,cropped_masked_img]=color_mask_function(cropped_img);
%  writeVideo(vidObj_crop,cropped_masked_img);
    
    
%  if(mod(k,100)==0)
%  display(['Frames cropped: ' num2str(k)]);
%  display(['Timestamp cropped: ' num2str(obj.CurrentTime)]);
%  end
%end

%face detection code
%face_detection(cropped_img);

%close(vidObj_crop);

%obj_1=VideoReader('final_video.avi');
%display(['total frames: ROI cropped video : ' num2str(obj_1.NumberOfFrames)]);
%display(['total time: ROI cropped video : ' num2str(obj_1.Duration)]);
