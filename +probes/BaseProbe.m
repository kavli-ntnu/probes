classdef (Abstract) BaseProbe < handle
    %BASEPROBE abstract probe base class
    %
    %This class provides a description of the physical geometry of a probe.
    
    methods (Abstract, Access = protected)
        
        % ONGETPROBEOUTLINE returns coordinates of the probe's outline
        coords = onGetProbeOutline(self)
        
        % ONGETSITEPOSITIONS returns coordinates for each site on the probe
        coords = onGetSitePositions(self)
        
        % ONGETSITESHANKINDEX returns the shank number of each site
        coords = onGetSiteShankInds(self)
        
        % ONGETSITEOUTLINE returns coordinates for a site of specified index
        coords = onGetSiteOutline(self, idx)
        
        % ONGETCHANNELINDS returns the recording channel for each site,
        % where this is hardware-defined. In the case that
        inds = onGetChannelInds(self)
    end
    
    methods (Access = protected)
        function inds = onGetReferenceSiteInds(self)
            % ONGETREFERENCESITEINDS returns indices of reference sites
            inds = [];
        end
    end
    
    methods
        
        % NSITES calculates the number of sites on the probe
        function n = nSites(self)
            coords = self.getSitePositions();
            n = size(coords, 1);
        end
        
        % GETPROBEOUTLINE returns the probe outline coordinates
        function coords = getProbeOutline(self)
            coords = self.onGetProbeOutline();
            checkCoords(coords);
        end
        
        % GETSITEPOSITIONS returns the coordinates for all site positions
        function coords = getSitePositions(self)
            coords = self.onGetSitePositions();
            checkCoords(coords);
        end
        
        function inds = getSiteShankInds(self)
            % GETSITESHANKINDS returns the chank index for every site
            inds = self.onGetSiteShankInds();
            assert( ...
                numel(inds) == self.nSites(), ...
                'probes:BaseProbe:getSiteShankInds:invalidSize', ...
                'The number of shand indices (%u) does not match the numer of sites (%u)', ...
                numel(inds), self.nSites());
        end
        
        % GETSITEOUTLINE returns site outline coordinates
        %
        % COORDS = OBJ.GETSITEOUTLINE(IDX) returns 2-column matrix COORDS,
        % specifying X/Y coordinates for the site with index IDX. The
        % coordinates are specified relative to the site's position, as
        % given by method "getSitePositions".
        function coords = getSiteOutline(self, idx)
            coords = self.onGetSiteOutline(idx);
            checkCoords(coords);
        end
        
        function inds = getChannelInds(self)
            % GETCHANNELINDS returns harware-specified channel indices
            inds = self.onGetChannelInds();
            assert( ...
                numel(inds) == self.nSites(), ...
                'probes:BaseProbe:getChannelInds:invalidSize', ...
                'The number of shank indices (%u) does not match the numer of sites (%u)', ...
                numel(inds), self.nSites());
        end
        
        function inds = getReferenceSiteInds(self)
            % INDS = GETREFERENCESITEINDS returns indices of ref sites
            inds = self.onGetReferenceSiteInds();
            assert(numel(inds) >= 0 && numel(inds) <= self.nSites(), ...
                'probes:BaseProbe:getReferenceSiteInds:invalidSize', ...
                'Invalid number of reference channels (%u)', numel(inds))
            assert(all(inds >= 0 &  inds <= self.nSites()), ...
                'probes:BaseProbe:getReferenceSiteInds:invalidInds', ...
                'Invalid reference site index');
        end
        
        function [d, dMin] = siteDists(self)
            % SITEDISTS intersite distances
            %
            % [D, DMIN] = OBJ.SITEDISTS() calculates the intersite distance
            % matrix D between every pair of sites. DMIN is a vector 
            % containing the distance of each site to its nearest neigbour.
            coords = self.getSitePositions();
            d = pdist(coords);
            d(d==0) = NaN;
            dMin = mean(min(d));
        end
        
        function AOff = applySitePositionOffsets(self, A, mode)
            assert(iscolumn(A) || size(A, 2)==self.nSites());
            coords = self.getSitePositions();
            if lower(mode) == 'x'
                offsets = coords(:, 1);
            elseif lower(mode) == 'y'
                offsets = coords(:, 2);
            else
                error('Invalid mode "%s"', mode);
            end
            AOff = bsxfun(@plus, A, offsets(:)');
        end
        
        function [h, P] = plot(self, varargin)
            %PLOT - draw the probe and site layout
            
            inp = inputParser();
            inp.addParameter('showColors', true);
            inp.addParameter('siteLabels', 'off');
            inp.addParameter('filled', true);
            inp.addParameter('bgColor', 'k');
            inp.addParameter('fgColor', [1 1 1]);
            inp.addParameter('probeColor', [0 0 0]+0.2);
            inp.addParameter('outline', true);
            inp.addParameter('siteOutline', false);
            inp.addParameter('siteColors', [0 0 0]+0.35);
            inp.addParameter('siteScalingFactor', 1);
            inp.addParameter('fontSize', 6);
            inp.addParameter('axes', gca());
            inp.parse(varargin{:});
            P = inp.Results;
            
            ax = P.axes;
            if size(P.siteColors, 1) == 1
                P.siteColors = repmat(P.siteColors, self.nSites, 1);
            else
                assert(size(P.siteColors, 1) == self.nSites, 'Number of rows in "siteColors" must equal number of sites');
            end
            
            if P.outline
                coords = self.getProbeOutline();
                h.probeOutline = patch(ax, coords(:, 1), coords(:, 2), P.probeColor, 'EdgeColor', mean([P.probeColor; P.fgColor]));
            end
            
            % Sites will be reordered by CHANNEL
            coords = self.getSitePositions();
            x = coords(:, 1);
            y = coords(:, 2);
            
            if ischar(P.siteLabels)
                switch lower(P.siteLabels)
                    case 'channel'
                        labelStrs = cellstr(num2str(self.getChannelInds()));
                    case 'site'
                        labelStrs = cellstr(num2str((1:self.nSites)'));
                    case 'off'
                    otherwise
                        error('Invalid label option "%s". Use "channel", "site" or "off".', P.siteLabels);
                end
            elseif iscell(P.siteLabels)
                labelStrs = self.siteLabels;
            end
            
            for s = 1:self.nSites
                coords = self.getSiteOutline(s) * P.siteScalingFactor;
                xTmp = x(s) + coords(:, 1);
                yTmp = y(s) + coords(:, 2);
                h.site(s, 1) = patch(ax, xTmp, yTmp, P.siteColors(s, :), 'EdgeColor', 'none');
                if P.siteOutline, h.Site(s).EdgeColor = P.fgColor; end
                if ~strcmpi(P.siteLabels, 'off')
                    text(ax, x(s)+coords(end, 1), y(s)+coords(end, 2), labelStrs{s}, ...
                        'horizontalAlignment', 'left', ...
                        'verticalAlignment', 'top', ...
                        'fontSize', P.fontSize, ...
                        'color', P.fgColor);
                end
            end
            
            ax.Color = P.bgColor;
            
        end
        
    end
    
end

function checkCoords(coords)
assert( ...
    ismatrix(coords) && size(coords, 2)==2, ...
    'probes:BaseProbe:coordsSize', ...
    'Coordinates must be a 2-column matrix');
end
