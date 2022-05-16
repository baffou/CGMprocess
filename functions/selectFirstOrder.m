function selectFirstOrder(h)
ha = gca;
hi = ha.Children;
image = hi.CData;
[Ny, Nx] = size(image);
[x,y] = ginput(1);

xc = Nx/2 + 1;
yc = Ny/2 + 1;
R = sqrt( (xc-x)^2 + (yc-y)^2 )/2;

h.UserData = FcropParameters(x, y, R, Nx, Ny);

xlim([1 Nx])
xlim([1 Ny])

drawCircle(h.UserData,h)
title('You can now close the window')
drawnow

