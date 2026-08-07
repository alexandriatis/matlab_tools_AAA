function framesize = savemovie_hd_AAA(vidfile,fig,framecount,framename,framesize,resolution)
% This function is designed to save movie frames in HD since matlab seems
% to struggle with the concept
%
% Alex Andriatis
% 2021-09-28

 exportgraphics(fig,framename,'Resolution',resolution);
 
% Make sure the movie frames are all the same size by padding with
% zeros
movieframe = imread(framename);
currentsize = size(movieframe);
if isempty(framesize)
    framesize = currentsize
end
if any(currentsize>framesize)
    framesize=currentsize
end
moviesize = 2*ceil(framesize./2);

% if any(currentsize~=framesize)
%     framesize
%     currentsize
%     warning(['Skipping frame ' num2str(framecount)]);
%     return
% end

% Pad frame with whitespace if frame size is not even
newframe = 255*ones([moviesize(1),moviesize(2),3]);
newframe(1:currentsize(1),1:currentsize(2),:)=movieframe;
newframe = uint8(newframe);

% Save movie file
writeVideo(vidfile, newframe);
end