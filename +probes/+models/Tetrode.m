classdef  Tetrode < probes.BaseProbe
    %TETRODE
    
    properties (Constant)
        WIRE_DIAMETER = 20
    end
    
    methods (Access = protected)
        
        % ONGETPROBEOUTLINE returns coordinates of the probe's outline
        function coords = onGetProbeOutline(self)
            coords = zeros(0, 2);
        end
        
        % ONGETSITEPOSITIONS returns coordinates for each site on the probe
        function coords = onGetSitePositions(self)
            d = self.WIRE_DIAMETER;
            x = [-1 -1 1 1]*d/2;
            y = [-1 1 1 -1]*d/2;
            coords = [x' y'];
        end
        
        % ONGETSITEOUTLINE returns coordinates for a site of specified index
        function coords = onGetSiteOutline(self, idx)
            theta = (1:64)'*2*pi/64;
            [x, y] = pol2cart(theta, self.WIRE_DIAMETER/2);
            coords = [x y];
        end
        
        function inds = onGetSiteShankInds(self)
            inds = ones(4, 1);
        end
        
        function inds = onGetChannelInds(self)
            inds = (1:4)';
        end
        
    end
    
end
