%%% ColorGrader - transform any video into a cinematic Almodóvar film
%
%%% Takes in an RGB image/video, increases relative saturation for selected
%   hues and desaturates remaining pixels. First generates test swatches to
%   inspect how chosen parameters will transform images. Generate function 
%   of hue-dependency by locating desired hues to stand out. Generate 
%   function of sat-dependency, hues to be made weaker are more
%   dramatically weakened.
%
%%% Can also boost chosen hues if required.
%
%%% Copyright Joshua Harvey 2017

clear all

vidn = '~/Downloads/MujerRetablos.mov'; % pathname of your video
Video = VideoReader(vidn);
mov = double(read(Video))/255;
[a,b,c,t] = size(mov);

tic

% specify hues to 'intensify' (H1, H2,... HN)
H1 = 55/255;
H2 = 175/255;
H = [H1 H2]; % H = [H1 H2... HN]
for k = t:-1:1 % Not vectorised, but faster
    
    imi = mov(:,:,:,k);
    % find pixels outside color band
    Himi = rgb2hsv(imi);
    uh = Himi(:,:,1);
    us = Himi(:,:,2);
    uv = Himi(:,:,3);
    
    
    % make scaling matrix
    
    for h = length(H):-1:1
        topdif = abs(uh-H(h));
        botdif = abs(uh-(H(h)+1));
        huedif = min(topdif,botdif);
        scales(:,:,h) = 1 + huedif*4;
    end
    
    scale = min(scales,[],3);
    
    
    rh = uh; % same hues
    rs = us.^scale ./(scale.^1.5); % desaturate by scale
    rv = uv; % same values
    
    R(:,:,1) = rh;
    R(:,:,2) = rs;
    R(:,:,3) = rv;
    r(:,:,:,k) = uint8(hsv2rgb(R)*255);
    
    if rem(k,20) == 0 % see progress
        disp(k)
    end
end
toc

% view video
implay(r)

%% write new video to file

newfilename = '~/Downloads/MujerRecolored.avi'; % specify new pathname for video
vidObj = VideoWriter(newfilename,'Uncompressed AVI'); 
open(vidObj);
writeVideo(vidObj,r);
close(vidObj)