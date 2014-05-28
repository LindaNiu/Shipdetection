function mask = rgbMaskTest(satIamge,terImage)
% Testing


 rCh = terImage(:,:,1);
 gCh = terImage(:,:,2);
 bCh = terImage(:,:,3);
 
 grayImage = rgb2gray(terImage);
 diff = imsubtract(bCh, grayImage);
 diff = medfilt2(diff, [3 3]);
 
 binImage = im2bw(diff, 0.15);
 
 figure;imshow(binImage);