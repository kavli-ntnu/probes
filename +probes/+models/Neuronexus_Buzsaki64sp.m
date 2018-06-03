classdef Neuronexus_Buzsaki64sp < probes.RegularMultiShankProbe
    %NEURONEXUS_BUZSAKI64SP
    
    methods
        function self = Neuronexus_Buzsaki64sp()
            self.nShanks = 6;
            self.shankSpacing = 200;
        end
    end
    
    methods (Access = protected)
        
        function coords = onGetExtraSiteCoords(self)
            x = [400 400 400 400];
            y = [1250, 2500, 3750, 5000];
            coords = [x' y'];
        end
        
        function coords = onGetShankOutline(self)
            x = [-52 -52 -29 0 29 52 52]/2;
            y = [5000 140 22 0 22 140 5000];
            coords = [x' y'];
        end
        
        function coords = onGetShankSiteCoords(self)
            x = [-37 -37 -29 -21 -17 0 17 25 33 37]/2;
            y = [180 140 100 60 20 0 40 80 120 160] + 22;
            coords = [x' y'];
        end
        
        function coords = onGetSiteOutline(self, idx)
            x = [-12 -12 12 12]/2;
            y = [-1 1 1 -1]*(13+1/3)/2;
            coords = [x' y'];
        end
        
        function inds = onGetChannelInds(self)
            inds = (1:64)';
        end
        
        function inds = onGetExtraSiteShankInds(self)
           inds =  [4 4 4 4]';
        end
            
            
    end
    


    
end

