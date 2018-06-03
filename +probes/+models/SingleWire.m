classdef  SingleWire < probes.BaseProbe
    %SINGLEWIRE
    
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
            coords = [0 0];
        end
        
        % ONGETSITEOUTLINE returns coordinates for a site of specified index
        function coords = onGetSiteOutline(self, idx)
            theta = (1:64)'*2*pi/64;
            [x, y] = pol2cart(theta, self.WIRE_DIAMETER/2);
            coords = [x y];
        end
        
        function inds = onGetSiteShankInds(self)
            inds = 1;
        end
        
        function inds = onGetChannelInds(self)
            inds = 1;
        end
    end
    
end
