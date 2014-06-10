function [lat,lon,xUp,yUp] = centroid2GeoPoint(x,y,gridTag,gridSet)
%
% x is the x-axis vector in centroid
% y is the y-axis vector in centroid
cell = gridSet(gridTag(1),gridTag(2),:);
k1 = (cell(1)-cell(2))/(128-1);
k2 = (cell(4)-cell(3))/(128-1);
b1 = cell(2)-(k1);
b2 = cell(3)-(k2);
lat = k1*y+b1;
lon = k2*x+b2;
xUp = (gridTag(1)-1)*128+x;
yUp = (gridTag(2)-1)*128+y;
end