function F = IJF(Sa,Sb)
% if ~exist('sigma_r','var')
%     sigma_r = 0.2;
% end

%% normalization step 1
GA = im2double(Sa); %eq 8
GB = im2double(Sb);
%% Smoothing step 2
r = 3;   % radius of the filtering window 
lambda = 0.01; % regulation parameter
[hei, wid] = size(GA); %definition of hei and wid
N = boxfilter(ones(hei, wid), r); %   a sliding window(it is defined as Ω in the paper) 
Ga = smoothing(GA, r, lambda,N); %eq9 adaptive local wiener filter
Gb = smoothing(GB, r, lambda,N);

%% Structure step 3& step 4
h = [1 -1];
% MA = Ga.*0;
% MB = MA;
% MAx = diff(Ga,1,1);
% MAx(hei, wid) = 0;
% MAy = diff(Ga,1,2);
% MAy(hei, wid) = 0;
% MA = abs(MAx) + abs(MAy);
% 
% MBx = diff(Gb,1,1);
% MBx(hei, wid) = 0;
% MBy = diff(Gb,1,2);
% MBy(hei, wid) = 0;
% MB = abs(MBx) + abs(MBy);

MA = abs(conv2(Ga,h,'same')) + ...
     abs(conv2(Ga,h','same')); %eq 13 magnitude of Ga
MB = abs(conv2(Gb,h,'same')) + ...
     abs(conv2(Gb,h','same')); %eq 13 magnitude of Gb
D = MA - MB; %eq14 decision map
IA = boxfilter(D,r) ./ N>0; %eq 15&16 calculation of salient structure
% imwrite(double(IA),'test.bmp')
%% IJF by blf
% Ga = GA;
% switch(Filter)
%     case 'BF'
%         minA = min(min(GA)); maxA = max(max(GA));
%         for t = 1:T
%             IA = double(IA > 0.5);
%         %     IA = guidedfilter(GA,IA, sigma_s, sigma_r^2);
%             IA = bilateralFilter(IA,GA,minA,maxA,r,sigma_r);%sigma_r=0.2
% %             imwrite(IA,strcat('ia',num2str(t),'.bmp'));
% %             figure,imshow(IA),colormap jet;colorbar
%         end
%% IJF by gif step 5,6,7
%     case 'GF'
%         mean_I = boxfilter(GA, r) ./ N;
%         mean_II = boxfilter(GA.*GA, r) ./ N;
%         var_I = mean_II - mean_I .* mean_I;
%         for t = 1:T
%             IA = double(IA > 0.5);
%             IA = IJF_guided(GA, IA, r, sigma_r^2,N,mean_I,var_I);
%         end
%     case 'DTF'
        for t = 1:3
            IA = double(IA > 0.5);
            IA = RF(IA, 10, 0.2, 1, GA);
        end
%         imwrite(IA,'ia1.bmp');
% end
% 
%% Result step 8
F = IA.*GA + (1-IA).*GB; %eq18 final fusion result
F = uint8(255*F);