clear all

vidn = '~/Downloads/MujerRetablos.mov';
Video = VideoReader(vidn);
mov = double(read(Video))/255;
[a,b,c,t] = size(mov);

% scaling factor for desaturation
% point of hue = 0 distance
% max distance from hue = 125
% max scale should be .^4 for distance = 125
% min scale should be .^1 for distance = 0
% small scale should be .^1.2 for distance = 20
tic

H1 = 55/255;
H2 = 175/255;
H = [H1 H2];
for k = 90:-1:1 % Not vectorised, but faster
    
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
    
    if rem(k,20) == 0
        disp(k)
    end
end
toc
% implay(r)

vidObj = VideoWriter('~/Downloads/MujerRecolored5.avi','Uncompressed AVI');
open(vidObj);
writeVideo(vidObj,r);
close(vidObj)