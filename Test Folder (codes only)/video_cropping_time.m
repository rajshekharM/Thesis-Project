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
%final_segment_of_input_video='final_video.avi';     %declare final_video.avi
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

%s=sprintf('del "%s"',final_segment_of_input_video);
%system(s);    

%handbrake for vropping video
s=sprintf('HandBrakeCLI.exe -i %s --start-at duration:%d  --stop-at duration:%d -e x264 --encoder-preset veryfast -q 10 --cfr -r %d -o %s', input_video, start_time, stop_time-start_time, fps,transcoded_segment_of_input_video);
system(s);

obj=VideoReader(transcoded_segment_of_input_video);
display(['total frames: time cropped video : ' num2str(obj.NumberOfFrames)]); 
display(['total time: time cropped video : ' num2str(obj.Duration)]); 

%Display first frame of time_cropped_video.avi

frame = read(obj, 1);
imshow(frame);


