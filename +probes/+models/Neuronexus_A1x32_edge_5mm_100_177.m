classdef Neuronexus_A1x32_edge_5mm_100_177 < probes.RegularMultiShankProbe
    %NEURONEXUS_A1x32_EDGE_5MM_100_177 silicon probe
    
    methods
        function self = Neuronexus_A1x32_edge_5mm_100_177()
            self.nShanks = 1;
            self.shankSpacing = 0;
        end
    end
    
    methods (Access = protected)
        
        function coords = onGetShankOutline(self)
            x = [-148 -148 148-56 148-56/2 148 148]/2;
            y = [5000 3100 50 0 50 5000];
            coords = [x' y'];
        end
        
        function coords = onGetShankSiteCoords(self)
            N_CHANNELS = 32;
            % Sites are on right-hand edge of shank. Subtract half a site's
            % width so they don't spill off the edge
            x = (148/2 - 12/2) * ones(N_CHANNELS, 1);
            y = (0:N_CHANNELS-1)'*100 + 50;
            coords = [x y];
        end
        
        function coords = onGetSiteOutline(self, idx)
            x = [-1; -1; 1; 1]*12/2;
            y = [-1; 1; 1; -1]*15/2;
            coords = [x y];
        end
        
        function inds = onGetChannelInds(self)
            inds = 1:self.nSites();
        end
            
            
    end
    
end

