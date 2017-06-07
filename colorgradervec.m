%%% A vectorized version of colorgraderscript.m
%
%%% This vectorized script actually takes longer than looping through frame
%   by frame on my machine, possibly because it requires more 4D matrices
%   to be constructed and manipulated.
%
%%% copyright Joshua Harvey 2017


vidn = '~/Downloads/MujerRetablos.mov'; % pathname of your video
Video = VideoReader(vidn);
mov = double(read(Video))/255;
[a,b,c,t] = size(mov);

clearvars -except vidn Video mov a b c t

tic

% specify hues to 'intensify' (H1, H2,... HN)

H1 = 0/255;
H2 = 125/255;
H = [H1 H2]; % H = [H1 H2... HN]

disp('Converting to hsv...')
for k = t:-1:1 % has to be done one 3D matrix at a time
    R(:,:,:,k) = rgb2hsv(mov(:,:,:,k));
end
    
% make scaling matrix based on hue
disp('Calculating scaling...')
for h = length(H):-1:1
    topdif = abs(R(:,:,1,:)-H(h));
    botdif = abs(R(:,:,1,:)-(H(h)+1));
    huedif = min(topdif,botdif);
    scales(:,:,h,:) = 1 + huedif*4;
end

scale = min(scales,[],3);
disp('Scaling in process...')
R(:,:,2,:) = R(:,:,2,:).^scale ./(scale.^1.5); % desaturate by scale

disp('Converting to rgb...')
for k = t:-1:1 % has to be done one 3D matrix at a time
    r(:,:,:,k) = uint8(hsv2rgb(R(:,:,:,k))*255);
end

toc

implay(r) % view newly graded video

%% write new video to file

newfilename = '~/Downloads/MujerRecolored.avi'; % specify new pathname for video
vidObj = VideoWriter(newfilename,'Uncompressed AVI'); 
open(vidObj);
writeVideo(vidObj,r);
close(vidObj)
