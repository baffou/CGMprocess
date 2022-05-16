function imagetf(A)

func=@(x)sqrt(sqrt(abs(x)));

imagesc(func(A))
colorbar
set(gca,'YDir','normal')
colormap(gca,'parula(1024)')
set(gca,'dataAspectRatio',[1 1 1])


