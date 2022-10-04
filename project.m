
%% salient structure extraction
% I1 = rgb2gray(imread('source241.jpg'));
% I2 = rgb2gray(imread('source242.jpg'));
I1 = niftiread('C:\Users\maria\Documents\MARIA\BioMed\SECOND_SEMESTER\ΕΙΚΟΝΑ\project2\MICCAI_BraTS2020_TrainingData\BraTS20_Training_001\BraTS20_Training_001_flair.nii'); %image import
I2 = niftiread('C:\Users\maria\Documents\MARIA\BioMed\SECOND_SEMESTER\ΕΙΚΟΝΑ\project2\MICCAI_BraTS2020_TrainingData\BraTS20_Training_001\BraTS20_Training_001_t1.nii'); %image import
I1=I1(:,:,75);
I1=squeeze(I1);
figure;imagesc(I1); colormap(gray);
I2=I2(:,:,75);
I2=squeeze(I2);
figure;imagesc(I2); colormap(gray);
% J(:,:,1) = I1; %tensor which includes both images
% J(:,:,2) = I2; 
 G1 = mat2gray(I1); %image normalization eq8
 G2 = mat2gray(I2);
%addaptive modified wiener filter
 r = 3;  % radius of the filtering window 
 lambda = 0.01; % regulation parameter
[hei, wid] = size(G1); %definition of hei and wid
N = boxfilter(ones(hei, wid), r); %   a sliding window centered at the pixel p
% (it is defined as Ω in the paper) 
Ga = smoothing(G1, r, lambda,N); %eq9 adaptive local wiener filter
Gb = smoothing(G2, r, lambda,N); %eq9
%decision map
h = [1 -1];
MA = abs(conv2(Ga,h,'same')) + ...
     abs(conv2(Ga,h','same')); %eq 13 magnitude of Ga
MB = abs(conv2(Gb,h,'same')) + ...
     abs(conv2(Gb,h','same')); %eq 13 magnitude of Gb
D = MA - MB; %eq14 decision map
IA = boxfilter(D,r) ./ N>0; %eq 15&16 calculation of salient structure 
%% the iterative joint filtering approach
% normalization step 1
GA = im2double(I1); %eq 8
GB = im2double(I2);
% Smoothing step 2
r = 3;   % radius of the filtering window 
lambda = 0.01; % regulation parameter
[hei, wid] = size(GA); %definition of hei and wid
N = boxfilter(ones(hei, wid), r); %   a sliding window(it is defined as Ω in the paper) 
Ga = smoothing(GA, r, lambda,N); %eq9 adaptive local wiener filter
Gb = smoothing(GB, r, lambda,N);

% Structure step 3& step 4
h = [1 -1];
MA = abs(conv2(Ga,h,'same')) + ...
     abs(conv2(Ga,h','same')); %eq 13 magnitude of Ga
MB = abs(conv2(Gb,h,'same')) + ...
     abs(conv2(Gb,h','same')); %eq 13 magnitude of Gb
D = MA - MB; %eq14 decision map
IA = boxfilter(D,r) ./ N>0; %eq 15&16 calculation of salient structure

%  step 5,6,7
        for t = 1:3
            IA = double(IA > 0.5); %eq 19 step(It − 0.5)
            IA = RF(IA, 10, 0.2, 1, GA); %10 is is a space domain scaling parameter
            %0.2 is a range domain scaling parameter
            %1 is the number of iterations
        end

% Result step 8
F = IA.*GA + (1-IA).*GB; %eq18 final fusion result
F = uint8(255*F);
F=squeeze(F);
% figure;imshow(F); %fusion result
figure;imagesc(F); colormap(gray)
title(' Final fusion result')