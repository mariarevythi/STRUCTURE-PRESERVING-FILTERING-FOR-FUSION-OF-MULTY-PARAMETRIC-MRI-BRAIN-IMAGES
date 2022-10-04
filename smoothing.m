function q = smoothing(I, r,eps,N) %adaptive local wiener filter
    mean_I = boxfilter(I, r) ./ N; %the mean of the image I in the window
    mean_II = boxfilter(I.*I, r) ./ N; %the mean of the square of I in the window 
    var_I = mean_II - mean_I .* mean_I; %calculation of the variance of image I in the window
    a = var_I ./ (var_I + eps); %calculation of constant k in the paper eq12
    q = mean_I+ a.*(I-mean_I); %eq10
end
