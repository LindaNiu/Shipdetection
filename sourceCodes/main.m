function centerSet = main(smsk,msk,gd2,type)
% MAIN IS the function to test the function implementation.

centerSet = zeros(1,4);
for i = 1:10
    for j = 1:10
        center = shipCentPoint(smsk,msk,'gridtag',[i,j],'gridData',gd2,'layer',2,'test',type);
        centerSet = [centerSet;center];
    end % j
end % i
figure,imshow(smsk);
hold on
[m,n] = size(centerSet);
for i = 1:m
    plot(centerSet(i,3),centerSet(i,4),'g+');
end