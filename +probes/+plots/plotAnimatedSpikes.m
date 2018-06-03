function h = plotAnimatedSpikes(chMap, y, fs, fLen, fInterval, spikeThresh, varargin)

inp = inputParser();
inp.addParameter('timeconst', 0.05);
inp.addParameter('clim', [0 0.1]);
inp.addParameter('videoFile', '');
inp.KeepUnmatched = true;
inp.parse(varargin{:});
P = inp.Results;

doVideo = ~isempty(P.videoFile);
if doVideo
    vWriter = VideoWriter(P.videoFile, 'MPEG-4');
    vWriter.FrameRate = 30;
    vWriter.Quality = 90;
    vWriter.open();
end

nSamp = size(y, 1);
nChan = chMap.nChannels;

fIntervalSamp = ceil(fInterval * fs);
fLenSamp = ceil(fLen * fs);
nF = ((nSamp - fLenSamp) / fIntervalSamp);
fStartInds = 1 : fIntervalSamp : (fIntervalSamp*(nF-1))+1;

[h, P2] = probes.plots.plotChannelMap(chMap, 'showColors', false);
for fd = fieldnames(P2)'
    P.(fd{1}) = P2.(fd{1});
end

clockPos = [0, -100];

coords = chMap.probe.getSitePositions();
lim = @(x, pad) mean([min(x) max(x)]) + [max(x)-min(x)]*[-1 1]*0.5*pad;
xLim = lim(coords(:, 1), 1.2);
yLim = lim(coords(:, 2), 1.2);
yLim(1) = clockPos(2)-100;
axis(P.axes, [xLim, yLim], 'off');

h.clock = text(clockPos(1), clockPos(2), '', 'color', 'w', 'fontName', 'consolas', 'fontSize', 20);
inds = 1:fLenSamp;

I = zeros(nChan, 1);

fig = ancestor(P.axes, 'figure');

for f = 1:nF
    yFrame = y(fStartInds(f) + inds, :);
    I = I * exp(-fIntervalSamp/fs/P.timeconst);
    isSpike = yFrame < spikeThresh;
    I = I + sum(isSpike)'/fLenSamp; % proportion of samples beyond thresh
    cols = probes.helpers.dataToRgb(I, P.clim, 'hot');
    for s = 1:chMap.nChannels
        h.site(s).FaceColor = cols(s, :);
    end
    tElapsed = fStartInds(f) / fs;
    h.clock.String = sprintf('%.3f', tElapsed);
    
    drawnow();
    
    if doVideo
        frame = getframe(fig);
        vWriter.writeVideo(frame);
    end
end

if doVideo
    vWriter.close();
end

end