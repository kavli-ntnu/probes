classdef Imec_Neuropixels_3a_opt4 < probes.models.Imec_Neuropixels_3a_10mm
    %IMEC_NEUROPIXELS_3A_OPT4 10-mm Neuropixels prbe
    
    methods (Access = protected)
        function n = onGetNChannels(self)
            n = 276;
        end
        
        % ONGETSITEPOSITIONS returns coordinates for each site on the probe
        function coords = onGetSitePositions(self)
            coords = getNeuropixelsSitePositions(self, 966);
        end
        
    end
    
end

