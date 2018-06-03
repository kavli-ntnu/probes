classdef Imec_Neuropixels_3a_5mm < probes.BaseProbe
    %IMEC_NEUROPIXELS_3A_5MM
    
    methods (Access = protected)
        
        function coords = onGetProbeOutline(self)
            x = [-1 -1 0 1 1] * 70/2;
            y =  [5000 190 0 190 5000];
            coords = [x', y'];
        end
        
        % ONGETSITEPOSITIONS returns coordinates for each site on the probe
        function coords = onGetSitePositions(self)
            x0 = [-24, 8, -8, 24];
            y0 = [20, 20, 40, 40] + 200;
            ySpacing = 40;
            nBlocks = 384/4;
            x = x0' * ones(1, nBlocks);
            y = y0' + (0:nBlocks-1)*ySpacing;
            coords = [x(:), y(:)];
        end
        
        % ONGETSITEOUTLINE returns coordinates for a site of specified index
        function coords = onGetSiteOutline(self, idx)
            x = [-1 -1 1 1]*12/2;
            y = [-1 1 1 -1]*12/2;
            coords = [x' y'];
        end
        
        function inds = onGetChannelInds(self)
            inds = (1:self.nSites())';
        end
        
        function inds = onGetSiteShankInds(self)
            inds = ones(self.nSites(), 1);
        end

    end
    
end

