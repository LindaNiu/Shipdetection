function  [centerPointInfo,subsatmsk,testMask] = shipCentPoint(smsk,msk,varargin)
% TODO 
% img :: satGSub
% mask:: 13*13 zeros
% thr :: 7658



if length(varargin) >= 1
     for idx = 1:2:length(varargin)
         switch lower(varargin{idx})
             case 'gridtag'
                 gridTag = varargin{idx+1};
             case 'layer'
                 layer = varargin{idx+1};
             case 'griddata'
                 gridSet = varargin{idx+1};
             case 'test'
                 type =  varargin{idx+1};
             otherwise
                error(['Unrecognized variable: ' varargin{idx}])
        end
    end
else 
    error('Wrong inputs.');
end

% Extract sub image which we want
[m,n,chs] = size(smsk);
row = gridTag(2);
col = gridTag(1);

if layer==1 || layer == 2
    gridlevel = 10;
elseif layer == 3 
    gridlevel = 8;
else 
    % TODO
end

x = 0:(m/gridlevel):m;
y = 0:(n/gridlevel):n;

% Get sub image from both loadmap mask and satellite mask
subsatmsk = smsk(x(row)+1:x(row+1),y(col)+1:y(col+1));
sublpmsk  = msk(x(row)+1:x(row+1),y(col)+1:y(col+1));
% Inverse the submsk.
sublpmsk = uint8(~(sublpmsk));

testMask = subsatmsk;
% TODO flag = sum(submsk(:))
flag = 0;
switch type
    case 1
        % Extract ships and groups of ship
        if (flag==0) % Equals 0 means that subsmsk is all in water area.
            subsatmsk(subsatmsk<108)=0;
            subsatmsk(subsatmsk>=108)=1;
        else  % Equals 1 means that subsmsk contains the land or not water area part
            subsatmsk=1;
        end
        % Dilate the image
        se90 = strel('line', 3, 90);
        se0 = strel('line', 3, 0);
        subsatmsk = imdilate(subsatmsk, [se90 se0]);
        % Fill Interior Gaps
        subsatmsk = imfill(subsatmsk, 'holes');
        
        % Label each blob so we can make measurements of it
        cc = bwconncomp(subsatmsk, 8);    
        % Find center point of ship or groups of ship.
        blobMeasurements = regionprops(cc,'Centroid');
    case 2
         % Extract ships and groups of ship
        if (flag==0) % Equals 0 means that subsmsk is all in water area.
            subsatmsk(subsatmsk<100)=0;
            subsatmsk(subsatmsk>=100)=1;
        else  % Equals 1 means that subsmsk contains the land or not water area part
            subsatmsk=1;
        end
        % Edge the outliner of ships
        [~, threshold] = edge(subsatmsk, 'sobel');
        fudgeFactor = .5;
        subsatmsk = edge(subsatmsk,'sobel', threshold * fudgeFactor);
        % Dilate the image
        se90 = strel('line', 3, 90);
        se0 = strel('line', 3, 0);
        subsatmsk = imdilate(subsatmsk, [se90 se0]);
        % Fill Interior Gaps
        subsatmsk = imfill(subsatmsk, 'holes');
        
        % Label each blob so we can make measurements of it
        cc = bwconncomp(subsatmsk, 8);    
        % Find center point of ship or groups of ship.
        blobMeasurements = regionprops(cc,'Centroid');
end
hold on
% Plot ship points on the image.
xCen = zeros(1,length(blobMeasurements));
yCen = zeros(1,length(blobMeasurements));
for i = 1:length(blobMeasurements)
    points = blobMeasurements(i).Centroid;
    xCen(i) = points(1);
    yCen(i) = points(2);
    plot(xCen(i),yCen(i),'g+');
        % ,...
        % 'LineWidth',5,...
        % 'MarkerSize',15);
end
hold off

% Convert X Y pixel points to lat and lon
% xInUplayerPixel,yInUplayerPixel: pixel value in sub image into uppler
% layer image.
[lat,lon,xInUplayerPixel,yInUplayerPixel] = centroid2GeoPoint(xCen,yCen,gridTag,gridSet);
% centerPointInfo

centerPointInfo = [lat;lon;xInUplayerPixel;yInUplayerPixel];
centerPointInfo = centerPointInfo';

end





