function [OPD, T, DWx, DWy, crops0] = CGMprocessManual(Itf, Ref,opt)
arguments
    Itf
    Ref
    opt.Gamma
    opt.distance
    opt.dxSize
    opt.zoom    = 1
    opt.auto logical = true
    opt.crops
    opt.method {mustBeMember(opt.method,{'fast','accurate'})} = 'fast'
    opt.Tnormalisation {mustBeMember(opt.Tnormalisation,{'division','subtraction'})} = 'division' % 'division' or 'subtraction'
end

[Ny, Nx] = size(Itf);
FItf = fftshift(fft2(Itf));
FRef = fftshift(fft2(Ref));

if ~isfield(opt,'crops') % if crop parameters are not specified
    % selection of a first order spot
    h = figure('Units','normalized','Position',[0 0 1 1]);
    zoom on
    imagetf(FItf)
    title('Please, zoom in on any first order spot and then click on the bottom-left button');
    FirstOrderButton = uicontrol('Parent',h,'Style','pushbutton','String','click 1st order','Position',[20 20 100 20]);
    set(FirstOrderButton, 'callback',{@(src,event)selectFirstOrder(h)})

    while isvalid(h)
        crops0 = h.UserData;
        pause(0.2)
        if ~isempty(crops0)
            pause(1.2)
            close(h)
        end
    end

    theta = crops0.angle;
    H = cell(2,1);
    Href = cell(2,1);
    [xx,yy] = meshgrid(1:Nx, 1:Ny);
    crops = crops0;
    for ii = 1:2
        R2C = (xx  - crops.x).^2/crops.Rx^2 + (yy - crops.y).^2/crops.Ry^2;
        circle = (R2C < 1); %circular mask
        FItfc = FItf.*circle;
        FRefc = FRef.*circle;
        H{ii} = circshift(FItfc, [-crops.shifty, -crops.shiftx]);
        Href{ii} = circshift(FRefc, [-crops.shifty, -crops.shiftx]);
        crops = crops.rotate90();
    end

else  % otherwise use the crop parameters x0, y0, R and theta defined by the user

    H = cell(2,1);
    Href = cell(2,1);
    [xx,yy] = meshgrid(1:Nx, 1:Ny);
    crops0 = opt.crops;
    crops = crops0;
    for ii = 1:2    % loop over the two orders
        R2C = (xx -crops.x).^2/crops.R^2 + (yy-crops.y).^2/crops.R^2;
        circle = (R2C < 1); %circular mask
        FItfc = FItf.*circle;
        FRefc = FRef.*circle;
        H{ii} = circshift(FItfc, [-round(crops.y) + (Ny/2+1), -round(crops.x) + (Nx/2+1)]);
        Href{ii} = circshift(FRefc, [-round(crops.y) + (Ny/2+1), -round(crops.x) + (Nx/2+1)]);
        crops=crops.rotate90();
    end

end
% Note: Please check that crops.zeta == Gamma*Z/(2*p).
% It not, then Gamma, Z and p values you entered are wrong.

% Computation of the OPD gradients



Ix = ifft2(ifftshift(H{1}));
Iy = ifft2(ifftshift(H{2}));
Irefx = ifft2(ifftshift(Href{1}));
Irefy = ifft2(ifftshift(Href{2}));
alpha = opt.Gamma/(4*pi*opt.distance);
DW1 = -alpha*angle(Ix.*conj(Irefx));
DW2 = -alpha*angle(Iy.*conj(Irefy));
DWx = crops0.angle.cos*DW1 - crops0.angle.sin*DW2;
DWy = crops0.angle.sin*DW1 + crops0.angle.cos*DW2;

% integration of the OPD gradients

switch opt.method
    case 'fast'
        [kx, ky] = meshgrid(1:Nx,1:Ny);
        kx = kx-Nx/2-1;
        ky = ky-Ny/2-1;
        kx(logical((kx==0).*(ky==0)))=Inf;
        ky(logical((kx==0).*(ky==0)))=Inf;

        W0 = ifft2(ifftshift((fftshift(fft2(DWx)) + 1i*fftshift(fft2(DWy)))./(1i*2*pi*(kx/Nx + 1i*ky/Ny))));
    case 'accurate' % D'Errico algrithm. Avoid rebounds on the boundary of the image, but slow.
        W0 = intgrad(DWx-mean(DWx(:)),DWy-mean(DWy(:)));
end

OPD = opt.dxSize/opt.zoom*real(W0);

% computation of the intensity map T

[xx,yy] = meshgrid(1:Nx, 1:Ny);
R2C = (xx  -Nx/2-1).^2/crops.Rx^2 + (yy - Ny/2-1).^2/crops.Ry^2;
circle = (R2C < 1); %circular mask
HT = FItf.*circle;
HTref = FRef.*circle;

switch opt.Tnormalisation 
    case 'division'
        T = ifft2(ifftshift(HT))./ifft2(ifftshift(HTref));

    case 'subtraction'
        T = ifft2(ifftshift(HT)) - ifft2(ifftshift(HTref));

end