function [xi_qi] = estimate_xi_qi_map(Z, tau,xi_e,xi_s,showFigure)
%--------------------------------------------------------------------------
% estimate_xi_q_map
%
% Estimates the spatial distribution of the quantum noise coefficient
% (xi_q) from a homogeneous calibration images.
%
% According to the quadratic noise model,
%
%   sigma^2 = xi_s^2*mu_l^2 + xi_q*mu_l + xi_e^2
%
% the local quantum noise coefficient can be estimated once the structural
% and electronic noise parameters are known. Local mean and variance maps
% are obtained using a moving-average window, and xi_q is computed for each
% pixel location. The resulting maps from all exposure conditions are then
% averaged and approximated by a second-order polynomial surface to reduce
% estimation noise.
%
% INPUTS
%   Z          : Stack of homogeneous calibration images
%
%   tau        : Detector offset estimated from detector response
%
%   xi_e       : Electronic noise parameter
%
%   xi_s       : Structural noise parameter
%
%   showFigure : Logical variable.
%                true  -> display xi_q map
%                false -> no figure (default)
%
% OUTPUTS
%   xi_qi      : Smoothed spatial map of the quantum noise coefficient
%
% NOTES
%   - Local statistics are computed using a 65×65 moving-average window.
%   - The first and last exposure conditions are discarded before averaging
%     to reduce boundary effects and improve estimation stability.
%--------------------------------------------------------------------------

if nargin<5
    showFigure = false;
end

%% Detrending of calibration images
% Low-frequency trends are removed to isolate noise fluctuations
for i = 1:size(Z,3)
    aux = dct2(Z(:,:,i));
    N = 10;
    Nmask = [0:N] + [0:N]' > N;
    aux(1:N+1,1:N+1) = aux(1:N+1,1:N+1) .* Nmask;
    Z_d(:,:,i) = idct2(aux);
end

%% Local mean (signal expectation) estimation
h = fspecial('average',65);
E_Z = imfilter(Z, h, 'symmetric');

%% Local variance estimation from detrended images
E_Z_d  = imfilter(Z_d, h, 'symmetric');
E_Z_d2 = imfilter(Z_d.^2, h, 'symmetric');
Var_real = E_Z_d2 - E_Z_d.^2;

xi_qi_all = (Var_real - xi_e^2 - xi_s^2.*(E_Z-tau).^2)./(E_Z-tau);

xi_qi_m = mean(xi_qi_all(:,:,2:end-1),3);


[X,Y]=meshgrid(1:size(xi_qi_m,2),1:size(xi_qi_m,1));
aux=xi_qi_m(:,:);
F=fit([X(:),Y(:)],aux(:),'poly22');
[X2,Y2]=meshgrid(1:size(aux,2),1:size(aux,1));
xi_qi(:,:)=F(X2,Y2);

if showFigure

    figure(...
        'Color','w',...
        'Units','centimeters',...
        'Position',[2 2 11 8]);

    imagesc(xi_qi)

    axis image

    colormap(summer)

    colorbar

    title('Estimated quantum noise coefficient map')

    xlabel('Detector column')

    ylabel('Detector row')

end


end
