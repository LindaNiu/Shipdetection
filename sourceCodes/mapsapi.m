function [g,curLatLonAxis,curGeoPixelRatio] = mapsapi(params,imageName)
% MAPSAPI creates an image from google map according to Google Maps Image
% API. 
% 
% INPUTS PARAMS contains {latitude(required), longitude(required), zoom(required)
% ,maptype, scale, size}
% Default zoom = 10
% Default maptype = 'terrain'
% Default scale = 2
% Default size = [640 640]
% Default format = png32
%
% OUTPUT G returns a image.
% OUTPUT CURLATLONAXIS returns current latitude longitude axis(or ranges).
% OUTPUT CURGEOPIXELRATIO returns the ratio of image pixel divided by
%        curLatLonAxis.(pixels/degree)
%
% Good Example 
% http://maps.googleapis.com/maps/api/staticmap?center=53.558572,9.9278215
% &zoom=10&size=640x380&scale=2&maptype=terrain&sensor=false
% http://maps.googleapis.com/maps/api/staticmap?center=53.558572,9.9278215
% &zoom=10&size=640x380&scale=2&maptype=satellite&sensor=false


% TESTING CODE
% params = struct('latitude',53.558572,'longitude',9.9278215);

params.showLabels=0;
% Check whether latitude and longitude in params exist or empty, because
% the latitude and longitude are required in Google Maps API.
if (~isfield(params, 'latitude')&~isfield(params, 'latitude')&isempty(params.latitude)&isempty(params.longitude))
    error('Inputs mistake of Latitude or longitude!');
end

% Check whether zoom is in params or is empty value. If it is, set the
% default value as 10.
if (~isfield(params,'zoom'))
    params.('zoom') = 10;
elseif (isempty(params.zoom))
    params.zoom = 10;
end

% Check whether size is in params or is empty value. If it is, set the
% default value as [640 640].
if (~isfield(params,'size'))
    params.('size') = [640 640];
elseif (isempty(params.size))
    params.size = [640 640];
end

if params.size(1) > 640
    params.size(1) = 640;
end
if params.size(2) > 640
    params.size(2) = 640;
end

% Check whether scale is in params or is empty value. If it is, set the
% default value as 2.
if (~isfield(params,'scale'))
    params.('scale') = 2;
elseif (isempty(params.scale))
    params.scale = 2;
end

% Check whether maptype is in params or is empty value. If it is, set the
% default value as terrain.
if (~isfield(params,'maptype'))
    params.('maptype') = 'terrain';
elseif (isempty(params.maptype))
    params.maptype = 'terrain';
end

% Set Axes 
scale = params.scale;
width = params.size(2)*scale;
height= params.size(1)*scale;% TODO *scale;
lat   = params.latitude;
lon   = params.longitude;
zoomlevel  = params.zoom;
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

% Current Ration
curAxis = axis;
xratio = diff(curLatLonAxis(1:2))/diff(curAxis(1:2));
yratio = diff(curLatLonAxis(3:4))/diff(curAxis(3:4));
curGeoPixelRatio = [xratio yratio];
    
    
% CONSTRUCT QUERY URL
preamble = 'http://maps.googleapis.com/maps/api/staticmap';
location = ['?center=' num2str(params.latitude,10) ',' num2str(params.longitude,10)];
zoomStr = ['&zoom=' num2str(params.zoom)];
sizeStr = ['&scale=' num2str(params.scale) '&size=' num2str(params.size(1)) 'x' num2str(params.size(2))];
maptypeStr = ['&maptype=' params.maptype ];
sensor = '&sensor=false';
format = '&format=png32';
if params.showLabels == 0
    labelsStr = '&style=feature:all|element:labels|visibility:off';
else
    labelsStr = '';
end



url = [preamble location zoomStr sizeStr maptypeStr format labelsStr sensor];


% Get the image
try
    imageFilePath = urlwrite(url,imageName);
catch % error downloading map
    warning(sprintf(['Unable to download map form Google Servers.\n' ...
        'Possible reasons: no network connection, quota exceeded, or some other error.\n' ...
        'Consider using an API key if quota problems persist.\n\n' ...
        'To debug, try pasting the following URL in your browser, which may result in a more informative error:\n%s'], url));
    varargout{1} = [];
    varargout{2} = [];
    varargout{3} = [];
    return
end
g = imread(imageFilePath,'png');

% Scale data and display image object 
imagesc(g)
% Set axis labels
xstep = diff(curLatLonAxis(1:2))/10;
xticklabels = curLatLonAxis(1):xstep:curLatLonAxis(2);
xticks = linspace(1, size(g, 2), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
ystep = diff(curLatLonAxis(3:4))/10;
yticklabels = curLatLonAxis(3):ystep:curLatLonAxis(4);
yticks = linspace(1, size(g, 1), numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', flipud(yticklabels(:)));
