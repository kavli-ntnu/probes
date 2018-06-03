classdef (Abstract) RegularMultiShankProbe < probes.BaseProbe
    %REGULARMULTISHANKPROBE si-probes with repeating configuration across shanks
    
    properties
        nShanks (1,1) uint8 = 1;
        shankSpacing (1,1) double = 0;
    end
    
    methods (Abstract, Access = protected)
        coords = onGetShankSiteCoords(self);
        coords = onGetShankOutline(self);
    end
    
    methods (Access = protected)
        
        function coords = onGetExtraSiteCoords(self)
            coords = zeros(0, 2);
        end
        
        function inds = onGetExtraSiteShankInds(self)
            inds = [];
        end
        
        function coords = onGetProbeOutline(self)
            coords = [];
            shankCoords = self.getShankOutline();
            for sh = 1:double(self.nShanks)
                shankX = (sh-1)*self.shankSpacing;
                coords = [coords; shankCoords+[shankX 0] ];
            end
        end
        
        function [coords] = onGetSitePositions(self)
            % GENERATE COORDS FOR PRESET
            coords = [];
            
            siteShankCoords = self.getShankSiteCoords();
            for sh = 1:double(self.nShanks)
                shankX = (sh-1)*self.shankSpacing;
                coords = [coords; siteShankCoords+[shankX 0] ];
            end
            coords = [coords; self.getExtraSiteCoords()];
        end
        
        function inds = onGetSiteShankInds(self)
            % ONGETSITESHANKINDS
            inds = meshgrid(1:self.nShanks(), ones(self.nSitesPerShank(), 1));
            indsExtra = self.onGetExtraSiteShankInds();
            inds = [inds(:); indsExtra];
        end
        
    end
    
    methods
        
        function coords = getShankOutline(self)
            coords = self.onGetShankOutline();
            checkCoords(coords);
        end
        
        function coords = getShankSiteCoords(self)
            coords = self.onGetShankSiteCoords();
            checkCoords(coords);
        end
        
        function coords = getExtraSiteCoords(self)
            coords = self.onGetExtraSiteCoords();
            shankInds = self.onGetExtraSiteShankInds();
            coords(:, 1) = coords(:, 1) + (shankInds-1)*self.shankSpacing;
            checkCoords(coords);
        end
        
        function inds = getExtraSiteShankInds(self)
            inds = self.onGetExtraSiteShankInds();
            assert( ...
               numel(inds) == self.nSites(), ...
               'probes:RegularMultiShankProbe:onGetSiteShankInds:invalidSize', ...
               'The number of shand indices (%u) does not match the numer of sites (%u)', ...
               numel(inds), self.nSites());
        end
            
        function n = nSitesPerShank(self)
            siteShankCoords = self.getShankSiteCoords();
            n = size(siteShankCoords, 1);
        end
        
    end
    
end

function checkCoords(coords)
assert( ...
    ismatrix(coords) && size(coords, 2)==2, ...
    'probes:RegularMultiShankProbe:coordsSize', ...
    'Coordinates must be a 2-column matrix');
end