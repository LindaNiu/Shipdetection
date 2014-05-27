function zoomLatLonAxis = getZoomLatLonAxis(curGeoPixelRatio,curlatlonAxis)
% Testing get LatlonAxis after zooming
axis
curZoomPixAxis = axis;
xratio = curGeoPixelRatio(1);
yratio = curGeoPixelRatio(2);

xMin = curZoomPixAxis(1)*xratio+curlatlonAxis(1);
xMax = curZoomPixAxis(2)*xratio+curlatlonAxis(1);
yMin = curZoomPixAxis(3)*yratio+curlatlonAxis(3);
yMax = curZoomPixAxis(4)*yratio+curlatlonAxis(3);

zoomLatLonAxis = [xMin xMax yMin yMax];