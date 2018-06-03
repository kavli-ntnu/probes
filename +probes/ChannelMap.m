classdef ChannelMap < matlab.mixin.Copyable
    % CHANNELMAP describes mapping of recorded channels onto a Probe
    
    properties (Dependent)
        % SITEINDS - probe site index for each channel
        siteInds (:,1) double
        
        % GROUPINDS - channel grouping indices
        %
        % In certain probe configurations, channels may be arranged in
        % distinct groups. This property allows such groupings to be
        % specified. It contains a N-element column vector of group indices
        % (integer values of 1 or greater), where N is the total number of
        % channels. Channels which are grouped together (i.e. share a
        % common group index) are considered together for the purpose of
        % spike sorting.
        groupInds (:,1) double
        
        % ENABLED - defines whether channel is "good"
        enabled (:,1) logical
        
        % REVERSECHANNELINDS - reverse indexing (probe site -> channel)
        reverseChannelInds
        
        % NGROUPS - number of channel groups
        %
        % This property is automatically determined from the number of
        % values in the "groupInds" property
        nGroups
        
        % NENABLED
        %
        % This property's value is automatially determined from the number
        % of "TRUE" elements in the contents of the "enabled" property.
        nEnabled
        
        % NCHANNELS - number of recording channels
        nChannels
    end
    
    properties (Access = protected)
        siteIndsImpl
        groupIndsImpl
        enabledImpl
    end
    
    properties (Hidden)
        % PROBENAME - string identifier for the model of the probe
        %
        % This property is automatically set when a ChannelMap is generated
        probeName (1,:) char
    end
    
    properties (Transient, SetAccess = protected)
        % PROBE - BaseProbe object
        %
        % The BaseProbe object stored in this property represents the
        % physical probe for which the channel map is designed.
        probe
    end
    
    properties (Hidden, Constant)
        VERSION = 3;
    end
    
    methods
        
        function self = ChannelMap(probe, siteInds, groups, enabled)
            % CHANNELMAP constructor
            %
            % A ChannelMap object represents the mapping of an probe's
            % recording sites onto sampled data channels.
            %
            % C = CHANNELMAP() creates blank ChannelMap, without
            % configurnig a source probe or channel-mapping attributes.
            %
            % C = CHANNELMAP(P) creates a ChannelMap for the probe
            % reprented by BaseProbe object P. The probe's default
            % channel mapping will be used.
            %
            % C = CHANNELMAP(P, ICHAN) additionally specifies a vector of
            % channel indices ICHAN. This must be the same length as the
            % number of recording sites on the probe. ICHAN(i)
            % represents the channel number associated with the ith
            % recording site of the probe. Where an probe recording
            % site has no corresponding channel in a recording, its value
            % in ICHAN should be zero. If ICHAN is left empty, the default
            % channel mapping for the probe will be used.
            %
            % C = CHANNELMAP(P, ICHAN, IGRP) also specifies the channel
            % group indices, IGRP. This specifies which channels are to be
            % grouped together for the purposes of spike sorting or other
            % analysis; groups will therefore normally comprise channels
            % that are located near to each other.
            %
            % C = CHANNELMAP(P, ICHAN, IGRP, ENABLED) also specifies
            % which sites are enabled for recording. ENABLED is a logical
            % vector with one site for each site of the probe. Set
            % ENABLED(i) to FALSE if the ith channel is a designated
            % reference or if it is defective.
            if nargin > 0
                
                assert(isa(probe, 'probes.BaseProbe') && isscalar(probe), ...
                    'Argument "probe" must be an BaseProbe object');
                
                nChannels = numel(siteInds);
                if nargin < 3 || isempty(groups), groups = ones(nChannels, 1); end
                if nargin < 4 || isempty(enabled), enabled = true(nChannels, 1); end
                
                self.probe = probe;
                self.probeName = class(probe);
                
                % Validate the consistency of the inds/groups/enabled
                % vectors, then assign to their props if OK
                self.updateChannels(siteInds, groups, enabled);
            end
        end
        
        function ASel = selectFromArray(self, A, mapping)
            if nargin < 3 || isempty(mapping), mapping = 'channel'; end
            assert(any(strcmpi(mapping, {'channel', 'site'})));
            if isvector(A), A = A(:)'; end
            arrayNChan = size(A, 2);
            assert(arrayNChan >= self.nChannels, ...
                'probes:ChannelMap:selectFromArray:insufficientChannes', ...
                'The array being selected from does not have enough channels (columns)');
            if strcmpi(mapping, 'site')
                % Array is site-ordered. Select using the site-index of
                % each channel (reverse channel inds)
                % Map SITE-ORDERED ==> CHANNEL-ORDERED
                ASel = A(:, self.siteInds);
            elseif strcmpi(mapping, 'channel')
                % Map CHANNEL-ORDERED ==> SITE-ORDERED
                ASel = A(:, self.reverseChannelInds);
            end
        end
        
        function AOff = applyChannelPositionOffsets(self, A, mode)
            if isvector(A)
                AOff = A;
            else
                % Convert channel-ordered matrix to site ordering
                AOff = self.selectFromArray(A, 'channel');
            end
            AOff = self.probe.applySitePositionOffsets(AOff, mode);
            AOff = self.selectFromArray(AOff, 'site');
        end
        
        function [d, dMin] = channelDists(self)
            % CHANNELDISTS interchannel distances
            %
            % [D, DMIN] = OBJ.CHANNELDISTS() calculates the interchannel distance
            % matrix D between every pair of channels. DMIN is a vector
            % containing the distance of each channel to its nearest neigbour.
            coords = self.getSitePositions();
            coords = self.selectFromArray(coords', 'site')';
            d = pdist(coords);
            d(d==0) = NaN;
            dMin = mean(min(d));
        end
        
        function inds = reorder(self, reorderBy, direction)
            % REORDER reorder channels according to position or group
            %
            % INDS = CHMAP.REORDER(ATTR) reorders the channels of
            % ChannelMap object CHMAP by the attribute named in ATTR. ATTR
            % can be either 'x' or 'y' to reorder by ascending x- or 
            % y-position of the recording sites, or 'group' to reorder 
            % by ascending channel group ID. INDS is a vector of sorting
            % indices, where the Nth element indicates the index of the
            % Nth channel in the original channel map.
            %
            % IND = CHMAP.REORDER(ATTR, DIR) additionally specifies the
            % sorting direction (may either by 'ascend' or 'descend').
            
            if nargin < 3 || isempty(direction), direction = 'ascend'; end
            siteCoords = self.probe.getSitePositions();
            siteCoords = siteCoords(self.siteInds, :);
            if isnumeric(reorderBy)
                inds = reorderBy;
                assert(numel(inds)==self.nChannels);
                assert(numel(unique(inds)==numel(inds)));
            elseif strcmpi(reorderBy, 'x')
                [~, inds] = sort(siteCoords(:, 1));
            elseif strcmpi(reorderBy, 'y')
                [~, inds] = sort(siteCoords(:, 2));
            elseif strcmpi(reorderBy, 'group')
                [~, inds] = sort(self.groupInds);
            else
                error('Invalid value of parameter ''reorderby''');
            end
            
            if strcmpi(direction, 'descend')
                inds = flip(inds);
            elseif ~strcmpi(direction, 'ascend')
                error('Invalid value for parameter ''direction''. Must be ''ascend'' or ''descend''');
            end
            self.updateChannels(self.siteInds(inds), self.groupInds(inds), self.enabled(inds));
        end
        
        function val = get.nGroups(self)
            val = numel(unique(self.groupInds));
        end
        
        function val = get.nChannels(self)
            val = numel(self.siteInds);
        end
        
        function val = get.nEnabled(self)
            val = numel(find(self.enabled));
        end
        
        function val = get.reverseChannelInds(self)
            [v, inds] = ismember((1:self.probe.nSites)', self.siteInds);
            val = inds;
        end
        
        function val = get.siteInds(self)
            val = self.siteIndsImpl;
        end
        
        function val = get.groupInds(self)
            val = self.groupIndsImpl;
        end
        
        function val = get.enabled(self)
            val = self.enabledImpl;
        end
        
        function set.siteInds(self, val)
            checkConsistency(val, self.groupInds, self.enabled);
            self.siteIndsImpl = val;
        end
        
        function set.groupInds(self, val)
            checkConsistency(self.siteInds, val, self.enabled);
            self.groupIndsImpl = val;
        end
        
        function set.enabled(self, val)
            checkConsistency(self.siteInds, self.groupInds, val);
            self.enabledImpl = val;
        end
        
    end
    
    methods (Hidden) 
        function updateChannels(self, siteInds, groups, enabled)
            % Internal method for updating the channel attribute vectors
            % and checking their consistency.
            nChannels = numel(siteInds);
            if nargin < 3 || isempty(groups), groups = ones(nChannels, 1); end
            if nargin < 4 || isempty(enabled), enabled = true(nChannels, 1); end
            checkConsistency(siteInds, groups, enabled);
            self.groupIndsImpl = groups(:);
            self.siteIndsImpl = siteInds(:);
            self.enabledImpl = enabled(:);
        end
    end
    
    
    methods (Static)
        
        function obj = loadobj(S)
            probe = feval(S.probeName);
            siteInds = S.siteIndsImpl;
            groupInds = S.groupIndsImpl;
            enabled = S.enabledImpl;
            obj = probes.ChannelMap(probe, siteInds, groupInds, enabled);
        end
        
    end
    
end

function checkConsistency(siteInds, groups, enabled)
nChannels = numel(siteInds);
assert(all([numel(siteInds), numel(groups), numel(enabled)] == nChannels), ...
    'probes:ChannelMap:badInputDims', ...
    'The number of elements in "siteChannelInds" and "siteGroups" must equal the number of sites on the probe (%u)', ...
    nChannels);
end