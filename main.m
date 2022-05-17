%% Postprocessing of cross-grating microscopy (CGM) interferograms
% (aka Quadriwave lateral shearing interferometry)
% G. Baffou
% CNRS - institut Fresnel
% May 2022

% Associated with the article:
% Quantitative phase microscopy using quadriwave lateral shearing interferometry (QLSI): principle, terminology, algorithm and grating shadow description.
% G. Baffou
% J. Phys. D: Appl. Phys. 54, 294002 (2021)

% Two sets of images are proposed, made using in silico experiments (see https://github.com/baffou/CGMinSilico)
% 1- Gaussian OPD profile
% 2- 100-nm Gold nanoparticles acquired with a 100x, NA1.0 objective lens

clear
close all

addpath(genpath(pwd))

%% experimental parameters
Gamma = 39e-6;  % period of the cross-grating (grexel size) [m]
d = 0.5e-3;     % grating-camera distance [m]
p = 6.5e-6;     % camera pixel size (dexel size) [m]
Z = 1;          % zoom of the relay lens (if any)


%% processing
% import the images

model = 'NP';
%model = 'Gaussian';

switch model
    case 'NP'
        folder='data/NPs/';
        Itf = readmatrix([folder 'interferogram.txt']);
        Ref = readmatrix([folder 'interferogram_ref.txt']);
    case 'Gaussian'
        folder='data/Gaussian/';
        Itf = readmatrix('data/Gaussian/interferogram.txt');
        Ref = readmatrix('data/Gaussian/interferogram_ref.txt');
end

% To test non-square images:
% Itf=Itf(end/4:3*end/4,1:end);
% Ref=Ref(end/4:3*end/4,1:end);

[Ny, Nx] = size(Itf);
FItf = fftshift(fft2(Itf));
FRef = fftshift(fft2(Ref));

% selection of a first order spot
h = figure('Units','normalized','Position',[0 0 1 1]);
zoom on
imagetf(FItf)
title('Please, zoom in on any first order spot and then click on the bottom-left button');
FirstOrderButton = uicontrol('Parent',h,'Style','pushbutton','String','click 1st order','Position',[20 20 100 20]);
set(FirstOrderButton, 'callback',{@(src,event)selectFirstOrder(h)})

while isvalid(h)
    crops = h.UserData;
    pause(0.2)
    if ~isempty(crops)
        pause(1.2)
        close(h)
    end
end

 % Note: Please check that crops.zeta == Gamma*Z/(2*p).
 % It not, then Gamma, Z and p values you entered are wrong.

% Computation of the OPD gradients

theta = crops.angle;
H = cell(2,1);
Href = cell(2,1);
[xx,yy] = meshgrid(1:Nx, 1:Ny);
for ii = 1:2
    R2C = (xx  -Nx/2-1-crops.shiftx).^2/crops.Rx^2 + (yy - Ny/2-1-crops.shifty).^2/crops.Ry^2;
    circle = (R2C < 1); %circular mask
    FItfc = FItf.*circle;
    FRefc = FRef.*circle;
    H{ii} = circshift(FItfc, [-crops.shifty, -crops.shiftx]);
    Href{ii} = circshift(FRefc, [-crops.shifty, -crops.shiftx]);
    crops = crops.rotate90();
end

Ix = ifft2(ifftshift(H{1}));
Iy = ifft2(ifftshift(H{2}));
Irefx = ifft2(ifftshift(Href{1}));
Irefy = ifft2(ifftshift(Href{2}));
alpha = Gamma/(4*pi*d);
DW1 = alpha*angle(Ix.*conj(Irefx));
DW2 = alpha*angle(Iy.*conj(Irefy));
DWx = theta.cos*DW1 - theta.sin*DW2;
DWy = theta.sin*DW1 + theta.cos*DW2;

% integration of the OPD gradients
[kx, ky] = meshgrid(1:Nx,1:Ny);
kx = kx-Nx/2-1;
ky = ky-Ny/2-1;
kx(logical((kx==0).*(ky==0)))=Inf;
ky(logical((kx==0).*(ky==0)))=Inf;

W0 = ifft2(ifftshift((fftshift(fft2(DWx)) + 1i*fftshift(fft2(DWy)))./(1i*2*pi*(kx/Nx + 1i*ky/Ny))));

W = p/Z*real(W0);

% computation of the intensity map T

[xx,yy] = meshgrid(1:Nx, 1:Ny);
R2C = (xx  -Nx/2-1).^2/crops.Rx^2 + (yy - Ny/2-1).^2/crops.Ry^2;
circle = (R2C < 1); %circular mask
H = FItf.*circle;
Href = FRef.*circle;

T = ifft2(ifftshift(H))./ifft2(ifftshift(Href));

%% Plot the results

OPD0 = readmatrix([folder 'OPD0.txt']);
T0 = readmatrix([folder 'T0.txt']);

figure('Units','normalized','Position',[0 0 1 1])

% plot the OPD images
ax1=subplot(2,3,1);
imagesc(1e9*OPD0)
xlabel('px')
ylabel('px')
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'YDir','normal')
cb1=colorbar('Fontsize',14);
colormap(flipud(phase1024()))
title('OPD (model)')
ylabel(cb1,'nm','FontSize',14)

ax2=subplot(2,3,2);
imagesc(1e9*W)
xlabel('px')
ylabel('px')
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'YDir','normal')
cb2=colorbar('Fontsize',14);
colormap(flipud(phase1024()))
title('OPD (calculated)')
ylabel(cb2,'nm','FontSize',14)

ax3=subplot(2,3,3);
hold on
plot(OPD0(round(end/2),:))
plot(W(round(end/2),:))
legend({'model','calculated'})

% plot the T images
ax4=subplot(2,3,4);
imagesc(T0)
xlabel('px')
ylabel('px')
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'YDir','normal')
colorbar
colormap(ax4,'Gray(1024')
title('Normalized intensity (model)')

ax5=subplot(2,3,5);
imagesc(T)
xlabel('px')
ylabel('px')
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'YDir','normal')
colorbar
colormap(ax5,'Gray(1024')
title('Normalized intensity (calculated)')

ax6=subplot(2,3,6);
hold on
plot(T0(round(end/2),:))
plot(T(round(end/2),:))
legend({'model','calculated'})
ha = gca;
ha.YLim(1) = 0;

zoom on
linkaxes([ax1,ax2,ax4,ax5])
linkaxes([ax3,ax6],'x')

%% Function that plots both T and W on the same figure
imagecgm(T,W)

