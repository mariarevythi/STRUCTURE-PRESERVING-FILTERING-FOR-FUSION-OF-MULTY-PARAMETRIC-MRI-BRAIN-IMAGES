function imDst = boxfilter(imSrc, r)

%   BOXFILTER   O(1) time box filtering using cumulative sum
%
%   - Definition imDst(x, y)=sum(sum(imSrc(x-r:x+r,y-r:y+r)));
%   - Running time independent of r; 
%   - Equivalent to the function: colfilt(imSrc, [2*r+1, 2*r+1], 'sliding', @sum);
%   - subdivides imSrc into regions of size 2*r+1 block-by-2*r+1 block blocks to save memory.
%Column-wise neighborhood operations
%   - But much faster.
%Box Filter is a low-pass filter that smooths the image by making each output pixel the average of the surrounding ones, removing details, noise and and edges from images
[hei, wid] = size(imSrc);
imDst = zeros(size(imSrc)); %definition of matrix imDst

% Y axis
imCum = cumsum(imSrc, 1); %calculation of cumulative sum over  Y axis

imDst(1:r+1, :) = imCum(1+r:2*r+1, :);%difference over Y axis 
imDst(r+2:hei-r, :) = imCum(2*r+2:hei, :) - imCum(1:hei-2*r-1, :); %constant part
imDst(hei-r+1:hei, :) = repmat(imCum(hei, :), [r, 1]) - imCum(hei-2*r:hei-r-1, :);

% X axis
imCum = cumsum(imDst, 2); %calculation of cumulative sum over X axis

imDst(:, 1:r+1) = imCum(:, 1+r:2*r+1); %difference over X axis
imDst(:, r+2:wid-r) = imCum(:, 2*r+2:wid) - imCum(:, 1:wid-2*r-1); 
imDst(:, wid-r+1:wid) = repmat(imCum(:, wid), [1, r]) - imCum(:, wid-2*r:wid-r-1);
end

