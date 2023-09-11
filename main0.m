%% Postprocessing of cross-grating microscopy (CGM) interferograms
% (aka Quadriwave lateral shearing interferometry)
% G. Baffou
% CNRS - institut Fresnel
% May 2022

% Associated with the article:
% Quantitative phase microscopy using quadriwave lateral shearing interferometry (QLSI): principle, terminology, algorithm and grating shadow description.
% G. Baffou
% J. Phys. D: Appl. Phys. 54, 294002 (2021)

% Simplest version of the code

clear

%% experimental parameters
Gamma = 39e-6;  % period of the cross-grating (grexel size) [m]
d = 0.5e-3;     % grating-camera distance [m]
p = 6.5e-6;     % camera pixel size (dexel size) [m]
Z = 1;          % zoom of the relay lens (if any)

%% import the images
Itf = readmatrix('data/NPs/interferogram.txt');
Ref = readmatrix('data/NPs/interferogram_ref.txt');

%% Fourier transform the images
[Ny, Nx] = size(Itf);
FItf = fftshift(fft2(Itf));
FRef = fftshift(fft2(Ref));

%% Demodulation the Fourier space
x0=458;y0=418;R=100;theta=0.6435;
H = cell(2,1);
Href = cell(2,1);
[xx,yy] = meshgrid(1:Nx, 1:Ny);
for ii = 1:2    % loop over the two orders
    R2C = (xx -x0).^2/R^2 + (yy-y0).^2/R^2;
    circle = (R2C < 1); %circular mask
    FItfc = FItf.*circle;
    FRefc = FRef.*circle;
    H{ii} = circshift(FItfc, [-y0 + (Ny/2+1), -x0 + (Nx/2+1)]);
    Href{ii} = circshift(FRefc, [-y0 + (Ny/2+1), -x0 + (Nx/2+1)]);
    x0=180;y0=458;
end

%% Back-Fourier transform
Ix = ifft2(ifftshift(H{1}));
Iy = ifft2(ifftshift(H{2}));
Irefx = ifft2(ifftshift(Href{1}));
Irefy = ifft2(ifftshift(Href{2}));
alpha = Gamma/(4*pi*d);
DW1 = alpha*angle(Ix.*conj(Irefx));
DW2 = alpha*angle(Iy.*conj(Irefy));
DWx = cos(theta)*DW1 - sin(theta)*DW2;
DWy = sin(theta)*DW1 + cos(theta)*DW2;

%% integration of the OPD gradients
[kx, ky] = meshgrid(1:Nx,1:Ny);
kx = kx-Nx/2-1; ky = ky-Ny/2-1;
kx(logical((kx==0).*(ky==0)))=Inf;
ky(logical((kx==0).*(ky==0)))=Inf;

OPD = p/Z*real(ifft2(ifftshift((fftshift(fft2(DWx)) + 1i*fftshift(fft2(DWy)))./(1i*2*pi*(kx/Nx + 1i*ky/Ny)))));

%% computation of the intensity map T
[xx,yy] = meshgrid(1:Nx, 1:Ny);
R2C = (xx - Nx/2-1).^2/R^2 + (yy - Ny/2-1).^2/R^2;
circle = (R2C < 1); %circular mask
H = FItf.*circle;
Href = FRef.*circle;
T = ifft2(ifftshift(H))./ifft2(ifftshift(Href));

%% Plot the results
figure
ax1=subplot(2,2,1);
imagesc(Itf)
set(gca,'DataAspectRatio',[1,1,1])
colorbar
title('interferogram')
ax2=subplot(2,2,2);
imagesc(OPD)
set(gca,'DataAspectRatio',[1,1,1])
colorbar
clim([-4 1]*1e-9)
title('OPD')
ax3=subplot(2,2,3);
imagesc(DWx)
set(gca,'DataAspectRatio',[1,1,1])
colorbar
colormap(gca,'Gray')
title('OPD gradient along x')
ax4=subplot(2,2,4);
imagesc(DWy)
set(gca,'DataAspectRatio',[1,1,1])
colorbar
colormap(gca,'Gray')
title('OPD gradient along y')
linkaxes([ax1,ax2,ax3,ax4])
zoom on

