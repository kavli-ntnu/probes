classdef (Abstract) Imec_Neuropixels_3a_10mm < probes.models.Imec_Neuropixels_3a
    %IMEC_NEUROPIXELS_3A_10mm
    
    methods (Access = protected)
        
        function coords = onGetProbeOutline(self)
            x = [-1 -1 0 1 1] * 70/2;
            y =  [10000 190 0 190 10000];
            coords = [x', y'];
        end
        
    end
    
end

