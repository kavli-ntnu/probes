function h = plotAnimatedSignal(chMap, y, fs, frameSize, frameInterval, varargin)

inp = inputParser();
inp.addParameter('normalize', 0.01);
inp.addParameter('mode', 'trace');
inp.addParameter('cLim', 'auto');
inp.addParameter('colorMap', hot());
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

[~, nnDist] = chMap.probe.siteDists();
meanNnDist = mean(nnDist);
if P.normalize
    y = reshape(zscore(double(y(:))), nSamp, nChan) * meanNnDist * P.normalize;
end

fIntervalSamp = ceil(frameInterval * fs);
fSzSamp = ceil(frameSize * fs);
nF = ((nSamp - fSzSamp) / fIntervalSamp);
fStartInds = 1 : fIntervalSamp : (fIntervalSamp*(nF-1))+1;

if strcmpi(P.mode, 'trace')
    y = chMap.applyChannelPositionOffsets(y, 'y');
    [h, P2] = probes.plots.plotSignal(nan(fSzSamp, nChan), varargin{:}, 'normalize', false);
elseif strcmpi(P.mode, 'color')
    [h, P2] = probes.plots.plotChannelMap('showColors', false);
    if strcmpi(P.cLim, 'auto')
        P.cLim = prctile(y(:), [0.5 99.5]);
    end
end

for fd = fieldnames(P2)'
    P.(fd{1}) = P2.(fd{1});
end

fig = ancestor(P.axes, 'figure');

coords = chMap.probe.getSitePositions();
lim = @(x, pad) mean([min(x) max(x)]) + (max(x)-min(x))*[-1 1]*0.5*pad;
xLim = lim(coords(:, 1), 1.2);
yLim = lim(coords(:, 2), 1.2);
clockPos = [0, -100];
yLim(1) = clockPos(2)-100;
axis(P.axes, [xLim, yLim], 'off');

h.clock = text(0, -100, '', 'color', 'w', 'fontName', 'consolas', 'fontSize', 20);

inds = 1:fSzSamp;
for f = 1:nF
    yFrame = y(fStartInds(f) + inds, :);
    if strcmpi(P.mode, 'trace')
        yFrame(end+1, :) = NaN;
        h.signal.YData = yFrame(:);
    elseif strcmpi(P.mode, 'color')
        yFrameMean = mean(yFrame);
        cols = probes.helpers.dataToRgb(yFrameMean', P.cLim, P.colorMap);
        for ch = 1:nChan
            if chMap.enabled(ch)
                h.site(ch).FaceColor = cols(ch, :);
            end
        end
    end
    
    % Update clock
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