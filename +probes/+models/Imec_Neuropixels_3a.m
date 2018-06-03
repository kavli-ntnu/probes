classdef (Abstract) Imec_Neuropixels_3a < probes.BaseProbe & ...
        probes.SwitchableMixin
    %IMEC_NEUROPIXELS_3A abstract class for Neuropixels phase-3A probes
    
    methods
        
        function siteInds = getSiteVSlice(self, startSiteIdx, stepSize, nSteps)
            ds = stepSize*4;
            siteInds = startSiteIdx : ds : startSiteIdx+(ds*nSteps-1);
        end
    end
    
    methods (Access = protected)
        
        % ONGETSITEOUTLINE returns coordinates for a site of specified index
        function coords = onGetSiteOutline(self, idx)
            x = [-1 -1 1 1]*12/2;
            y = [-1 1 1 -1]*12/2;
            coords = [x' y'];
        end
        
        function inds = onGetChannelInds(self)
            % By default select the first bank of sites. Unselected sites
            % are indicated by 0-valued channel inds
            inds = mod( (1:self.nSites())' - 1, self.getNChannels()) + 1;
        end
        
        function inds = onGetSiteShankInds(self)
            inds = ones(self.nSites(), 1);
        end
        
        function inds = onGetSiteBanks(self)
            inds = ceil((1:self.nSites())' / self.getNChannels());
        end
        
        function inds = onGetReferenceSiteInds(self)
            inds0 = [37, 76, 113, 152, 189, 228, 265, 304, 341, 380];
            bankNSites = numel(find(self.onGetSiteBanks()==1));
            inds0 = inds0(inds0 <= bankNSites);
            inds = inds0+(bankNSites*(0:3)');
            inds = sort(inds(:));
            inds(inds > self.nSites()) = [];
        end
        
        function [x, y] = getNeuropixelsSiteTile(self)
            % Helper returning the basic checkerboard site tile
            x = [-8, 24, -24, 8]';
            y = [0, 0, 20, 20]';
        end
        
        function coords = getNeuropixelsSitePositions(self, nSites)
            % Generate N-site tilings of the checkerboard pattern
            [x0, y0] = self.getNeuropixelsSiteTile();
            y0 = y0 + 220;
            ySpacing = 40;
            nBlocks = ceil(nSites/4);
            x = x0 * ones(1, nBlocks);
            y = y0 + (0:nBlocks-1)*ySpacing;
            coords = [x(:), y(:)];
            coords = coords(1:nSites, :);
        end
        
    end
    
end

