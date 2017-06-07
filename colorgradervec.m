%%% THIS ACTUALLY TAKES LONGER - because more 4D MATRICES?


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

clearvars -except vidn Video mov a b c t

tic

H1 = 0/255;
H2 = 125/255;
H = [H1 H2];
disp('Converting to hsv...')
for k = 90:-1:1 % has to be done one 3D matrix at a time
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
for k = 90:-1:1 % has to be done one 3D matrix at a time
    r(:,:,:,k) = uint8(hsv2rgb(R(:,:,:,k))*255);
end

toc

implay(r)

vidObj = VideoWriter('~/Downloads/MujerRecolored5.avi','Uncompressed AVI');
open(vidObj);
writeVideo(vidObj,r);
close(vidObj)


% t:-1:1