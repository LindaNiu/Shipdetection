function [mask,sateMask,gridData,zoomlevel] = getMask(hueLow,hueHigh,smallestAcceptableArea,varargin)
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
    layer = 1;
    currentAxis = axis;
    [lon,lat,zoomlevel] = setCenterPoint(currentAxis); % setCenterPoin is an inner function.
    
elseif length(varargin) >= 1
    for idx = 1:2:length(varargin)
        switch lower(varargin{idx})
            case 'gridcell'
                gridcell = varargin{idx+1};
                [lon,lat,zoomlevel] = setCenterPoint(gridcell);
            case 'apikey'
                isApiKeyFlag = varargin{idx+1};
            case 'layer'
                layer = varargin{idx+1};
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
    gMsk = hsvMask(hueLow,hueHigh,terImage,smallestAcceptableArea);
elseif zoomlevel > 12
    gMsk = grayMask(terImage);
end

mask = gMsk;
figure;
imshow(mask,[]);
% Maximize the figure window.
% set(gcf, 'Position', get(0, 'ScreenSize'));

% Testing
% Fill in any holes in the regions, since they are most likely red also.
% g = uint8(imfill(mask, 'holes'))

satMask = gMsk;
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



% Scale data and display image object 
figure;
%imshow(sateMask);
imagesc(sateMask);
% Set axis labels
if layer==1||layer == 2
    gridlevel = 10;
elseif layer == 3 
    gridlevel = 8;
else 
    % TODO
end

xstep = diff(curLatLonAxis(1:2))/gridlevel;
ystep = diff(curLatLonAxis(3:4))/gridlevel;

xticklabels = curLatLonAxis(1):xstep:curLatLonAxis(2);
xticks = linspace(1, size(mask, 2), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);

yticklabels = curLatLonAxis(3):ystep:curLatLonAxis(4);
yticks = linspace(1, size(mask, 1), numel(yticklabels));
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
% Create a grid data
% M and N are one cell's tags. 
% L have 6 elements. 4 are latitude and longitude values. One is
% flag value (0or1) to set whether this cell has water or river areas. The
% other is zoomlevel information for this grid cell.
m = length(xticklabels)-1;
n = length(yticklabels)-1;
l = 5; 
% gridData=zeros(m*n,4);
gridData = zeros(m,n,l);

for i = 1:m
    for j = 1:n
        for k = 1:l
            switch k
                case 1
                    gridData(i,j,k) = xticklabels(i);
                case 2
                    gridData(i,j,k) = xticklabels(i+1);
                case 3
                    gridData(i,j,k) = yticklabels(11-j);
                case 4
                    gridData(i,j,k) = yticklabels(12-j);
                case 5
                    % TODO filter the area whether has water or not.
                    gridData(i,j,k) = 0; % Default value 0 as including water area.
                    
                otherwise
                    error('Wrong inputs');
            end % switch
        end % k
    end % j
end % i

end % End function GETMASK().

% INNER FUNCTIONS

% SETCENTERPOINT RETURNS three outputs of longitude, latitude and zoomlevel
% according to the specific range of gridcell or current axis.
% 
% RangeOfLocation can be two type of data. It can be gridcell data from the
% grid data, or can be current axis.
function [lon lat zoomlevel] = setCenterPoint(rangeOflocation)

zoomlevel = getZoomLevel(rangeOflocation) % TODO
lon = sum(rangeOflocation(1:2))/2;
lat = sum(rangeOflocation(3:4))/2;

end

% Mask functions

function mask = hsvMask(hueLow,hueHigh,terImage,smallestAcceptableArea)
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

% g
function mask = grayMask(terImage)
mask = rgb2gray(terImage);
mask(mask<173|mask>175) = 0;
mask(mask>=173&mask<=175) = 1;
end



