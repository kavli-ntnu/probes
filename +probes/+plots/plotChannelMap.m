function [h, P] = plotChannelMap(chMap, varargin)
%PLOTCHANNELMAP - draw probe with channel layout
%
% Parse arguments not handled by probe plotting method
inp = inputParser();
inp.KeepUnmatched = true;
inp.addParameter('highlight', 'enabled');
inp.addParameter('channelGroupColors', colorcube(chMap.nGroups + 5));
inp.parse(varargin{:});
P2 = inp.Results;

if strcmpi(P2.highlight, 'group')
    groupCols = P2.channelGroupColors;
    chanCols = groupCols(chMap.groupInds, :);
elseif strcmpi(P2.highlight, 'enabled')
    col = [1 1 0.5];
    chanCols = zeros(chMap.nChannels, 3);
    for n = 1:3
        chanCols(chMap.enabled, n) = col(n);
    end
end

prb = chMap.probe;
siteCols = zeros(prb.nSites, 3);
for c = 1:3
    siteCols(chMap.siteInds, c) = chanCols(:, c);
end

[h, P] = prb.plot(varargin{:}, 'siteColors', siteCols);

v = chMap.enabled;
if any(~v)
    coords = prb.getSitePositions();
    inds = chMap.siteInds;
    x = coords(inds, 1);
    y = coords(inds, 2);
    h.badSites = line(P.axes, x(~v), y(~v), ...
        'lineStyle', 'none', ...
        'marker', 'x', ...
        'color', 'k', 'markerSize', 1);
end

end