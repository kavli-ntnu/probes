function h = plotAnimatedSignal(chMap, y, fs, varargin)

inp = inputParser();
inp.addParameter('normalize', 0.2);
inp.addParameter('mode', 'trace');
inp.addParameter('cLim', 'auto');
inp.addParameter('colorMap', hot());
inp.addParameter('videoFile', '');
inp.addParameter('frameLength', 1/fs);
inp.addParameter('frameInterval', 1/fs);
inp.addParameter('slowToRealTime', true);
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

fIntervalSamp = ceil(P.frameInterval * fs);
fSzSamp = ceil(P.frameLength * fs);
nF = ((nSamp - fSzSamp) / fIntervalSamp);
fStartInds = 1 : fIntervalSamp : (fIntervalSamp*(nF-1))+1;

if strcmpi(P.mode, 'trace')
    y = chMap.applyChannelPositionOffsets(y, 'y');
    [h, P2] = probes.plots.plotSignal(chMap, nan(fSzSamp, nChan), varargin{:}, 'normalize', false);
elseif strcmpi(P.mode, 'color')
    [h, P2] = probes.plots.plotChannelMap(chMap, 'showColors', false);
    if strcmpi(P.cLim, 'auto')
        P.cLim = prctile(y(:), [0.5 99.5]);
    end
else
    error('Invalid plotting mode "%s". Must be "trace" or "color"', P.mode);
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
tic();

inds = 1:fSzSamp;
for f = 1:nF
    yFrame = y(fStartInds(f) + inds, :);
    if strcmpi(P.mode, 'trace')
        yFrame(end+1, :) = NaN;
        h.signal.YData = yFrame(:);
    elseif strcmpi(P.mode, 'color')
        yFrameMean = mean(yFrame, 1);
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
    
    if doVideo
        frame = getframe(fig);
        vWriter.writeVideo(frame);
    end
    
    drawnow();
    
    if P.slowToRealTime
        timeToPlot = toc();
        if timeToPlot < 1/fs
            tDelay = 1/fs - timeToPlot;
            if tDelay > 0
                pause(tDelay);
            end
        end
        tic();
    end
    
end

toc();

if doVideo
    vWriter.close();
end

end