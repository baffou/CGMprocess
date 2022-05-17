function h=imagecgm(T,W)
% Function that plots both intensity and wavefront images on the same
% figure

if nargout
    h=figure('Units','normalized','Position',[0 0.25 1 0.5]);
else
    figure('Units','normalized','Position',[0 0.25 1 0.5])

end

ax1=subplot(1,2,1);
imagesc(T)
xlabel('px')
ylabel('px')
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'YDir','normal')
colorbar
colormap(ax1,'Gray')
title('Normalized intensity (calculated)')

ax2=subplot(1,2,2);
imagesc(W)
xlabel('px')
ylabel('px')
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'YDir','normal')
cb2=colorbar('Fontsize',14);
colormap(ax2,flipud(phase1024()))
title('OPD (calculated)')
ylabel(cb2,'nm','FontSize',14)

linkaxes([ax1,ax2])
