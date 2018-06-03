classdef (Abstract) SwitchableMixin < handle
    %SWITCHABLEMIXIN add switchable channel functionality
    %
    %In probes such as Neuropixels, the number of electrodes is several
    %times larger than the number of recording channels. Each recording
    %channel may be switched to select from of a set of available
    %electrodes. This mixin class adds switching functionality via the
    %abstract method "onGetSiteBanks", which subclasses must define to
    %return the channel "bank" index for each electrode site.
    
    properties
    end
    
    methods (Abstract, Access=protected)
        inds = onGetSiteBanks(self)
    end
    
    methods (Access=protected)
        function n = onGetNChannels(self)
            n = numel(self.channelInds());
        end
    end
    
    methods
        function n = getNChannels(self)
            n = self.onGetNChannels();
        end
        
        function inds = getSiteBanks(self)
            inds = self.onGetSiteBanks();
        end
        
        function siteInds = bank2site(self, channelInds, bankInds)
           allChans = self.getChannelInds();
           allBanks = self.getSiteBanks();
           siteInds = zeros(size(channelInds));
           for ch = 1:numel(channelInds)
               v = allChans==channelInds(ch) & allBanks==bankInds(ch);
               siteInds(ch) = find(v);
           end
        end
        
    end
    
end

