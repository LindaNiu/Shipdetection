function g = shipCentPoint(img,threshold)
% TODO 
% img :: satGSub
% mask:: 13*13 zeros
% thr :: 7658

% padding
[m,n] = size(img)
m = m+2;
n = n+2;
g = zeros(m,n);
g(1:m-2,1:n-2) = img;
x = 1:13:m
y = 1:13:n
mask=zeros(13);


t1 = length(x)-1
t2 = length(y)-1

for i = 1:length(x)-1
    for j = 1:length(y)-1
        sub = img(x(i):x(i+1),y(j):y(j+1));
        if (sum(sub(:))<threshold)
            g(x(i):x(i+1),y(j):y(j+1)) = mask;
        end
    end
end




