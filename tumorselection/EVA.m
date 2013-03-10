function [ p ] = EVA( img )
%EVA Summary of this function goes here
%   Detailed explanation goes here
%   compute dian rui du

%todo:1. prepair data
%todo:2. compute ruidu for each pixel
%todo:3. normalize

img = double(img);
[m n] = size(img);
E = zeros(m,n);
img = [img(1,:);img;img(end,:)];
img = [img(:,1) img img(:,end)];

for i = 2:m+1
    for j = 2:n+1
%         E(i-1,j-1) = (4+2*sqrt(2))*img(i,j) - img(i,j-1) - img(i,j+1) - img(i-1,j) - img(i+1,j)...
%                      - (1/sqrt(2))*(img(i-1,j-1)+img(i-1,j+1)+img(i+1,j-1)+img(i+1,j+1));
          E(i-1,j-1)=abs(img(i,j)-img(i,j-1))+abs(img(i,j)-img(i,j+1))+abs(img(i,j)-img(i-1,j))...
              +abs(img(i,j)-img(i+1,j))+(1/sqrt(2))*(abs(img(i,j)-img(i-1,j-1))+abs(img(i,j)-...
              img(i-1,j+1))+abs(img(i,j)-img(i+1,j-1)+abs(img(i,j)-img(i+1,j+1))));
    end
end

p = sum(E(:))/(m*n);
end