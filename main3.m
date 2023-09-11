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

% This version proposes to manually select the 1 st order


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
    case 'Gaussian'
        folder='data/Gaussian/';
end
Itf = readmatrix([folder 'interferogram.txt']);
Ref = readmatrix([folder 'interferogram_ref.txt']);

% To test non-square images:
% Itf=Itf(end/4:3*end/4,1:end);
% Ref=Ref(end/4:3*end/4,1:end);


if 1 % manual mode

[OPD, T, DWx, DWy, crops] = CGMprocess(Itf, Ref,'Gamma',Gamma, ...
                                'distance',d,'dxSize',p,'zoom',Z, ...
                                 'method','accurate');
else % automatic mode, once you have done the manual mode once, and collected the crops information

[OPD, T] = CGMprocess(Itf, Ref,'Gamma',Gamma, ...
                                'distance',d,'dxSize',p,'zoom',Z, ...
                                 'method','accurate','crops',crops);
end
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
imagesc(1e9*OPD)
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
plot(OPD(round(end/2),:))
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
imagecgm(T,OPD)

