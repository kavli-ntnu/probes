classdef Neuronexus_Buzsaki256 < probes.RegularMultiShankProbe
    %NEURONEXUS_BUZSAKI256
    %   
    
    methods
        function self = Neuronexus_Buzsaki256()
            self.nShanks = 8;
            self.shankSpacing = 300;
        end
    end
    
    methods (Access = protected)
        
        function coords = onGetExtraSiteCoords(self)
            coords = zeros(0, 2);
        end
        
        function coords = onGetShankOutline(self)
            x = [-200 -90 -13 -0 13 90 200]/2;
            y = [5000 1600 15 0 15 1600 5000];
            coords = [x' y'];
        end
        
        function coords = onGetShankSiteCoords(self)
            x = ones(1, 32);
            y = 15 + 50*(1:32);
            coords = [x' y'];
        end
        
        function coords = onGetSiteOutline(self, idx)
            x = [-1 -1 1 1] * 11.43 * 0.5;
            y = [-1 1 1 -1] * 14 * 0.5;
            coords = [x' y'];
        end
            
        function inds = onGetChannelInds(self)
            % TODO: fix!
            inds = (1:self.nSites())';
        end
            
    end
    


    
end

