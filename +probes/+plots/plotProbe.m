function [h, P] = plotProbe(probe, varargin)
%PLOTPROBE create a 2-D plot of the probe layout

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
inp.addParameter('zoomOnSites', false);
inp.addParameter('fontSize', 6);
inp.addParameter('axes', gca());
inp.parse(varargin{:});
P = inp.Results;

ax = P.axes;
if size(P.siteColors, 1) == 1
    P.siteColors = repmat(P.siteColors, probe.nSites, 1);
else
    assert(size(P.siteColors, 1) == probe.nSites, 'Number of rows in "siteColors" must equal number of sites');
end

if P.outline
    coords = probe.getProbeOutline();
    h.probeOutline = patch(ax, coords(:, 1), coords(:, 2), P.probeColor, 'EdgeColor', mean([P.probeColor; P.fgColor]));
end

% Sites will be reordered by CHANNEL
coords = probe.getSitePositions();
x = coords(:, 1);
y = coords(:, 2);

if ischar(P.siteLabels)
    switch lower(P.siteLabels)
        case 'channel'
            labelStrs = cellstr(num2str(probe.getChannelInds()));
        case 'site'
            labelStrs = cellstr(num2str((1:probe.nSites)'));
        case 'off'
        otherwise
            error('Invalid label option "%s". Use "channel", "site" or "off".', P.siteLabels);
    end
elseif iscell(P.siteLabels)
    labelStrs = probe.siteLabels;
end

for s = 1:probe.nSites
    coords = probe.getSiteOutline(s) * P.siteScalingFactor;
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

if P.zoomOnSites
    coords = probe.getSitePositions();
    rng = [min(coords); max(coords)];
    rng = mean(rng) + (diff(rng).*[-1; 1]*0.75);
    axis(ax, 'equal');
    ax.XLim = rng(:, 1);
    ax.YLim = rng(:, 2);
end

end

