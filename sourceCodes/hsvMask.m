function [mask sateMask] = hsvMask(hueLow,hueHigh,smallestAcceptableArea,varargin)
% HSVMASK MASKS the requried color object.
% Varargin CONTAINS [satImage,terImage]. SatImage is a satellite image.
% terImage is a terrain image.
%
% Blue domain test:
% [pixelCounts values] = hist(hImage,500)
% figure:
% bar(values, pixelCounts);
% set(gcf, 'units','normalized','outerposition',[0 0 1 1])
%

isApiKeyFlag = 0;%'AIzaSyCg0-ikB-TFJbNLyNrMxeUkf8bMmlWjq_c'
if length(varargin)==0
    currentAxis = axis
    zoomlevel = getZoomLevel(currentAxis)

    lon = sum(currentAxis(1:2))/2
    lat = sum(currentAxis(3:4))/2

    % APIKEY IS testing now.
    satParams = struct('latitude',lat,'longitude',lon,'zoom',zoomlevel,'maptype','satellite');
    terParams = struct('latitude',lat,'longitude',lon,'zoom',zoomlevel,'maptype','terrain');
    
else length(varargin)==1
    satParams = varargin{1};
    satParams.zoom=10;
    satParams.maptype = 'satellite';
    terParams = varargin{1};
    terParams.zoom=10;
    terParams.maptype = 'roadmap';
end

if isApiKeyFlag==0
    satParams.apikey = '';
    terParams.apikey = '';
else
    satParams.apikey = 'AIzaSyCg0-ikB-TFJbNLyNrMxeUkf8bMmlWjq_c';
    terParams.apikey = 'AIzaSyCg0-ikB-TFJbNLyNrMxeUkf8bMmlWjq_c';
end

% Get images.
satImage = mapsapi(satParams,'tmp1.png');
terImage = mapsapi(terParams,'tmp2.png');

% Convert RGB image to HSV
hsvImage = rgb2hsv(terImage);
% Extract out the H, S, and V images individually
hImage = hsvImage(:,:,1);
sImage = hsvImage(:,:,2);
vImage = hsvImage(:,:,3);

hueThresholdLow = hueLow;
hueThresholdHigh = hueHigh;
saturationThresholdLow = graythresh(sImage);
saturationThresholdHigh = 1.0;
valueThresholdLow = graythresh(vImage);
valueThresholdHigh = 1.0;

% Now apply each color band's particular thresholds to the color band
hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the right parts of the image.
mask = uint8(hueMask & saturationMask & valueMask);

% Keep areas only if they're bigger than this.
% Get rid of small objects.  Note: bwareaopen returns a logical.
mask = uint8(bwareaopen(mask, smallestAcceptableArea));

% Smooth the border using a morphological closing operation, imclose().
%structuringElement = strel('disk', 4);
%mask = imclose(mask, structuringElement);

g = mask;
figure;
imshow(g,[]);
% Maximize the figure window.
% set(gcf, 'Position', get(0, 'ScreenSize'));

% Testing
% Fill in any holes in the regions, since they are most likely red also.
% g = uint8(imfill(mask, 'holes'))

satMask = mask;
maskedImageR = satMask .* satImage(:,:,1);
maskedImageG = satMask .* satImage(:,:,2);
maskedImageB = satMask .* satImage(:,:,3);
sateMask = cat(3, maskedImageR, maskedImageG, maskedImageB);
figure;
imshow(sateMask);

% Set Axes 
scale = 2;%satParams.scale;
width = 640*scale;%params.size(2)*scale;
height= 640*scale;%params.size(1)*scale;% TODO *scale;
%lat   = satParams.latitude;
%lon   = satParams.longitude;
curLatLonAxis = getCurAxis(width,height,lat,lon,zoomlevel,scale)
if curLatLonAxis(1)<-180
    curLatLonAxis(1)=-180;
end
if curLatLonAxis(2)>180
    curLatLonAxis(2)=180;
end
if curLatLonAxis(3)<-85
    curLatLonAxis(3)=-85;
end
if curLatLonAxis(4)>85
    curLatLonAxis(4)=85;
end

%Current Ratio
%curAxis = axis
%xratio = diff(curLatLonAxis(1:2))/diff(curAxis(1:2));
%yratio = diff(curLatLonAxis(3:4))/diff(curAxis(3:4));
%curGeo= [xratio yratio];

% Scale data and display image object 
figure;
%imshow(sateMask);
imagesc(sateMask);
% Set axis labels
xstep = diff(curLatLonAxis(1:2))/10;
xticklabels = curLatLonAxis(1):xstep:curLatLonAxis(2);
xticks = linspace(1, size(g, 2), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
ystep = diff(curLatLonAxis(3:4))/10;
yticklabels = curLatLonAxis(3):ystep:curLatLonAxis(4);
yticks = linspace(1, size(g, 1), numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', flipud(yticklabels(:)));
% Add grid over the image.
hold on

M = diff(curLatLonAxis(3:4));
N = diff(curLatLonAxis(1:2));

for k=curLatLonAxis(1):xstep:curLatLonAxis(2);
    x = [curLatLonAxis(1) curLatLonAxis(2)];
    y = [k k];
    plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','k','LineStyle',':');
end 

hold off




	



