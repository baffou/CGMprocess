function linkAxes
childList=get(gcf,'Children');
if isa(childList(1),'matlab.graphics.layout.TiledChartLayout')
    childList=childList.Children;
end
Nc=numel(childList);

n=0;
ax=matlab.graphics.axis.Axes.empty(4,0);
for ic=1:Nc
    if isa(childList(ic),'matlab.graphics.axis.Axes')
        n=n+1;
        ax(n)=childList(ic);
    end
end

linkaxes(ax)

zoom on


