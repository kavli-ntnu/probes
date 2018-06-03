classdef Neuronexus_A4x64_poly2_10mm_23s_200_160 < probes.RegularMultiShankProbe
    %NEURONEXUS_BUZSAKI64SP
    %   
    % Custom design used for MEC implants in Fernandez-Ruiz et al., 2017
    
    methods
        function self = Neuronexus_A4x64_poly2_10mm_23s_200_160()
            self.nShanks = 4;
            self.shankSpacing = 200;
        end
    end
    
    methods (Access = protected)
        
        function coords = onGetExtraSiteCoords(self)
            coords = zeros(0, 2);
        end
        
        function coords = onGetShankOutline(self)
            x = [-144 -144 -114 -114 -52 -32 0 32 52 114 114 144 144]/2;
            y = [10000 2000 1750 1449 80 30 0 30 80 1449 1759 2000 10000];
            coords = [x' y'];
        end
        
        function coords = onGetShankSiteCoords(self)
            spc = 46;
            yOff = 50;
            x = [-ones(1, 32) ones(1, 32)] * 10;
            yL = 0.5*spc : spc : 31.5*spc;
            yR = 0 : spc : 31*spc;
            y = yOff + [yL yR];
            coords = [x' y'];
        end
        
        function coords = onGetSiteOutline(self, idx)
            theta = (1:32)/32 * 2*pi;
            siteArea = 177;
            siteRadius = sqrt(177/pi);
            [x, y] = pol2cart(theta, siteRadius);
            coords = [x' y'];
        end
        
        function inds = onGetChannelInds(self)
            inds = (1:self.nSites())';
        end 
            
    end
    


    
end

