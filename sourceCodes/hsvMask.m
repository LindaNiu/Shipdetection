function [mask sateMask gridData] = hsvMask(hueLow,hueHigh,smallestAcceptableArea,varargin)
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
if isempty(varargin) == 1
    currentAxis = axis;
    [lon lat zoomlevel] = setCenterPoint(currentAxis); % setCenterPoin is an inner function.
    
elseif length(varargin) >= 1
    for idx = 1:2:length(varargin)
        switch lower(varargin{idx})
            case 'gridcell'
                gridcell = varargin{idx+1};
                [lon lat zoomlevel] = setCenterPoint(gridcell);
            case 'apikey'
                isApiKeyFlag = varargin{idx+1};
            otherwise
                error(['Unrecognized variable: ' varargin{idx}])
        end
    end
else 
    error('Wrong inputs.');
end

% set satellite image and terrain image or roadmap image's data struct
satParams = struct('latitude',lat,'longitude',lon,'zoom',zoomlevel,'maptype','satellite');
terParams = struct('latitude',lat,'longitude',lon,'zoom',zoomlevel,'maptype','terrain');

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

% Mask process
if (zoomlevel <= 12)
    mask = hsvMask1(hueLow,hueHigh,terImage,smallestAcceptableArea);
elseif zoomlevel >= 15
    mask = grayMask(terImage);
end

% % Convert RGB image to HSV
% hsvImage = rgb2hsv(terImage);
% % Extract out the H, S, and V images individually
% hImage = hsvImage(:,:,1);
% sImage = hsvImage(:,:,2);
% vImage = hsvImage(:,:,3);
% 
% hueThresholdLow = hueLow;
% hueThresholdHigh = hueHigh;
% saturationThresholdLow = graythresh(sImage);
% saturationThresholdHigh = 1.0;
% valueThresholdLow = graythresh(vImage);
% valueThresholdHigh = 1.0;
% 
% % Now apply each color band's particular thresholds to the color band
% hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
% saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
% valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);
% 
% % Combine the masks to find where all 3 are "true."
% % Then we will have the mask of only the right parts of the image.
% mask = uint8(hueMask & saturationMask & valueMask);
% 
% % Keep areas only if they're bigger than this.
% % Get rid of small objects.  Note: bwareaopen returns a logical.
% mask = uint8(bwareaopen(mask, smallestAcceptableArea));
% 
% % Smooth the border using a morphological closing operation, imclose().
% %structuringElement = strel('disk', 4);
% %mask = imclose(mask, structuringElement);

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
curLatLonAxis = getCurAxis(width,height,lat,lon,zoomlevel,scale);
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

M = size(sateMask,1);
N = size(sateMask,2);

step = 128;
for k = 1:step:M
    x = [1 N]; 
    y = [k k];
    plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','k','LineStyle',':');
end
for k = 1:step:N 
    x = [k k]; 
    y = [1 M];
   plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','k','LineStyle',':');
end
hold off

% TODO
% To develop a grid data with 4 data and one zoomlevel
m = length(xticklabels)-1;
n = length(yticklabels)-1;
gridData=zeros(m*n,4);
for i = 1:m
    line = (i-1)*10; % Line of gridData matrix.
    for j = 1:n
        gridData(line+j,:)=[xticklabels(i) xticklabels(i+1) yticklabels(j) yticklabels(j+1)];
    end % j
end % i
end

% SETCENTERPOINT RETURNS three outputs of longitude, latitude and zoomlevel
% according to the specific range of gridcell or current axis.
% 
% RangeOfLocation can be two type of data. It can be gridcell data from the
% grid data, or can be current axis.
function [lon lat zoomlevel] = setCenterPoint(rangeOflocation)

zoomlevel = getZoomLevel(rangeOflocation);
lon = sum(rangeOflocation(1:2))/2;
lat = sum(rangeOflocation(3:4))/2;

end

% Mask functions

function mask = hsvMask1(hueLow,hueHigh,terImage,smallestAcceptableArea)
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
end

% 
function mask = grayMask(terImage)
mask = rgb2gray(terImage);
mask(mask<=170|mask>=179) = 0;
mask(mask>170&mask<179) = 1;
end






	



