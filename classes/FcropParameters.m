classdef FcropParameters  %parameters of the crop in the Fourier plane
    
    properties
        x           double
        y           double
        R           double
        Nx          {mustBeInteger,mustBePositive}
        Ny          {mustBeInteger,mustBePositive}
    end
    properties(Dependent)
        shiftx
        shifty
        angle
        Rx
        Ry
        zeta
    end
    
    methods
        
        function obj = FcropParameters(x,y,R,Nx,Ny)
            arguments
                x = []
                y = []
                R = []
                Nx = []
                Ny = []
            end
            obj.Nx = Nx;
            obj.Ny = Ny;
            obj.x = x;
            obj.y = y;
            obj.R = R;
        end
        
        function obj = set.x(obj,x0)
            if ~isempty(x0)
                if x0 >= 0 && x0 <= obj.Nx
                    obj.x = x0;
                else
                    error(['wrong value for x, which equals ' num2str(x0) ' while Nx = ' num2str(obj.Nx) '.'])
                end
            end
        end
        
        function obj = set.y(obj,y0)
            if ~isempty(y0)
                if y0 >= 0 && y0 <= obj.Ny
                    obj.y = y0;
                else
                    error(['wrong value for y, which equals ' num2str(y0) ' while Nx = ' num2str(obj.Ny) '.'])
                end
            end
        end
        
        function val = get.shiftx(obj)
            val = round(obj.x - (obj.Nx/2+1));
        end
        
        function val = get.shifty(obj)
            val = round(obj.y - (obj.Ny/2+1));
        end
        
        function val = get.angle(obj)
            nshiftx = obj.shiftx/obj.Nx;
            nshifty = obj.shifty/obj.Ny;
            
            nshiftr = sqrt(nshiftx^2+nshifty^2);
            
            val.cos = nshiftx/nshiftr;
            val.sin = nshifty/nshiftr;
        end
        
        function obj2 = rotate90(obj)
            Nratio = obj.Ny/obj.Nx;
            x0 = obj.Nx/2+1;
            y0 = obj.Ny/2+1;
            dx = (obj.x-x0);
            dy = obj.y-y0;
            
            x0 = x0*Nratio;
            dx = dx*Nratio;
            
            x2 = x0-dy;
            y2 = y0+dx;
            
            x2 = x2/Nratio;
           
            obj2 = FcropParameters(x2, y2, obj.R, obj.Nx, obj.Ny);
        end
        
        function obj2 = rotate180(obj)
            x0 = obj.Nx/2 + 1;
            y0 = obj.Ny/2 + 1;
            dx = obj.x - x0;
            dy = obj.y - y0;
            
            x2 = x0 - dx;
            y2 = y0 - dy;
            
            obj2 = FcropParameters(x2, y2, obj.R, obj.Nx, obj.Ny);
        end

        function val = get.Rx(obj)
            val=obj.Nx/obj.zeta/2; % radius of the ellipse along x
        end
        
        function val = get.Ry(obj)
            val=obj.Ny/obj.zeta/2; % radius of the ellipse along y
        end

        function val = get.zeta(obj)
            val = 1/sqrt((obj.shiftx/obj.Nx)^2+(obj.shifty/obj.Nx)^2); % radius of the ellipse along y
        end

        function drawCircle(obj,h)
            figure(h)
            zoom out
            resetplotview(h,'InitializeCurrentView');
            hold on
            th = 0:pi/50:2*pi;
            xunit = obj.Rx*cos(th) + obj.x;
            yunit = obj.Ry*sin(th) + obj.y;
            plot(xunit, yunit,'LineWidth',3,'color',[0.8,0.3,0.2]);
            hold off
            drawnow

        end
            


        
    end
end
