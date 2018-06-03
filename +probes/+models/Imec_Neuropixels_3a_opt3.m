classdef Imec_Neuropixels_3a_opt3 < probes.models.Imec_Neuropixels_3a_10mm
    %IMEC_NEUROPIXELS_3A_OPT3 10-mm Neuropixels prbe
    
    methods (Access = protected)
        function n = onGetNChannels(self)
            n = 384;
        end
        
        % ONGETSITEPOSITIONS returns coordinates for each site on the probe
        function coords = onGetSitePositions(self)
            coords = getNeuropixelsSitePositions(self, 960);
        end
        
    end
    
end

