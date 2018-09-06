function [h, P] = plotSignal(chMap, y, varargin)

inp = inputParser();
inp.addParameter('color', [1, 1, 1]);
inp.addParameter('lineWidth', get(0, 'defaultLineLineWidth'));
inp.addParameter('normalize', 0.01);
inp.KeepUnmatched = true;
inp.parse(varargin{:});
P = inp.Results;

assert(size(y, 2) == chMap.nChannels);
nSamp = size(y, 1);
nChan = chMap.nChannels;

% Scale X and Y according to distance between sites
[~, nnDist] = chMap.probe.siteDists();
meanNnDist = mean(nnDist);
x = linspace(-0.3, 0.3, nSamp)' * meanNnDist;
if P.normalize
    y = reshape(zscore(double(y(:))), nSamp, nChan) * meanNnDist * P.normalize;
end

[h, P2] = probes.plots.plotProbe(chMap.probe);
for fd = fieldnames(P2)'
    P.(fd{1}) = P2.(fd{1});
end

xA = chMap.applyChannelPositionOffsets(x, 'x');
yA = chMap.applyChannelPositionOffsets(y, 'y');
xA(nSamp+1, :) = NaN;
yA(nSamp+1, :) = NaN;

h.signal = line(P2.axes, xA(:), yA(:), 'color', P.color, 'lineWidth', P.lineWidth);

end