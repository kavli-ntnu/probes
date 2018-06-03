classdef Neuronexus_Buzsaki64 < probes.RegularMultiShankProbe
    %NEURONEXUS_BUZSAKI64 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function self = Neuronexus_Buzsaki64()
            self.nShanks = 8;
            self.shankSpacing = 200;
        end
    end
    
    methods (Access = protected)
        
        function coords = onGetShankOutline(self)
            x = [-52 -52 -29 0 29 52 52]/2;
            y = [5000 140 22 0 22 140 5000];
            coords = [x' y'];
        end
        
        function coords = onGetShankSiteCoords(self)
            x = [-37 -29 -21 -17 0 17 25 33]/2;
            y = [140 100 60 20 0 40 80 120] + 22;
            coords = [x' y'];
        end
        
        function coords = onGetSiteOutline(self, idx)
            x = [-12 -12 12 12]/2;
            y = [-1 1 1 -1]*(13+1/3)/2;
            coords = [x' y'];
        end
        
        function inds = onGetChannelInds(self)
            inds = 1:self.nSites();
        end
            
            
    end
    


    
end

