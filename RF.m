function F = RF(img, sigma_s, sigma_r, num_iterations, joint_image)
    I = double(img);
    J = double(joint_image);    
    [h, w, num_joint_channels] = size(J);
    dIcdx = diff(J, 1, 2); %calculation of Differences along x-axis
    dIcdy = diff(J, 1, 1); %calculation of Differences along y-axis
    
    dIdx = zeros(h,w);
    dIdy = zeros(h,w);   
    % Calculation l1-norm distance of neighbor pixels.
    for c = 1:num_joint_channels
        dIdx(:,2:end) = dIdx(:,2:end) + abs( dIcdx(:,:,c) );
        dIdy(2:end,:) = dIdy(2:end,:) + abs( dIcdy(:,:,c) );
    end
     % Calculations of  the derivatives of the horizontal and vertical domain transforms.
    dHdx = (1 + sigma_s/sigma_r * dIdx); %eq 11 in the second paper
    dVdy = (1 + sigma_s/sigma_r * dIdy); %is the distance between neighbor samples
    % The vertical pass is performed using a transposed image.
    dVdy = dVdy';
     %% Perform the filtering.
     N = num_iterations;
    F = I;
    
    sigma_H = sigma_s;
    
    for i = 0:num_iterations - 1
        % calculation of  s the standard deviation for the kernel used in the i-th iteration
        sigma_H_i = sigma_H * sqrt(3) * 2^(N - (i + 1)) / sqrt(4^N - 1); %eq 14 from the second paper
    
        F = TransformedDomainRecursiveFilter_Horizontal(F, dHdx, sigma_H_i);
        F = TransformedDomainRecursiveFilter_Horizontal(F', dVdy, sigma_H_i);
        F = F';
    end
end
    %% Recursive filter.
    function F = TransformedDomainRecursiveFilter_Horizontal(I, D, sigma)

   
    a = exp(-sqrt(2) / sigma); %calculation of  RF feedback coefficient (appendix of second paper)
    
    F = I;
    V = a.^D;
    
    [~, w, num_channels] = size(I);
    
    % Left -> Right filter.
    for i = 2:w
        for c = 1:num_channels
            F(:,i,c) = F(:,i,c) + V(:,i) .* ( F(:,i - 1,c) - F(:,i,c) ); %eq 21 in the second paper
        end
    end
    
    % Right -> Left filter.
    for i = w-1:-1:1
        for c = 1:num_channels
            F(:,i,c) = F(:,i,c) + V(:,i+1) .* ( F(:,i + 1,c) - F(:,i,c) ); %eq 21 in the second paper
        end
    end

end 