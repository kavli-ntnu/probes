%% Plot some preset probe models
import probes.models.*
import probes.plots.*
import probes.ChannelMap

probeModels = {
    Neuronexus_A4x64_poly2_10mm_23s_200_160()
    Neuronexus_Buzsaki256()
    Imec_Neuropixels_3a_5mm()
    };

probeNames = {
    'Neuronexus poly2 64'
    'Neuronexus Buzsaki 256'
    'IMEC phase-3a 5-mm'
    };

nProbes = numel(probeModels);

figure('color','k');
for p = 1:nProbes
    subplot(1, nProbes, p);
    axis off
    prb = probeModels{p};
    plotProbe(prb, ...
        'zoomOnSites', true, ...
        'siteColor', [1, 1, 0], ...
        'siteScalingFactor', 1.5);
    title(probeNames{p}, 'color', 'w');
end

%% Plot value of a variable on the probe recording sites

prb = Neuronexus_A4x64_poly2_10mm_23s_200_160();
coords = prb.getSitePositions();

% Simulate a variable whose value is a function of distance from one point
% on the probe
cen = mean(coords);
d = hypot(coords(:, 1)-cen(1), coords(:, 2)-cen(2));
d = d/max(d);
y = exp(-d);
y = y/max(y) + 0.1*randn(size(d));
y(y<0) = 0;
y(y>1) = 1;
cols = interp1(1:128, hot(128), y*128, 'linear', 1);

figure('color', 'k');
axis off
plotProbe(prb, ...
    'zoomOnSites', true, ...
    'siteColor', cols, ...
    'siteScalingFactor', 1.5);

%% Plot a 1-D timeseries variable

chMap = ChannelMap(prb, (1:prb.nSites)');

fs = 20;
nSamp = fs*10;
y = exp(-d');
y = y/max(y) + randn(nSamp, prb.nSites);

[ii,jj] = ndgrid((-fs:fs)*5, -10:10);
k = mvnpdf([ii(:), jj(:)], [0, 0], [fs, 1]);
k = reshape(k, size(ii));
k = k/sum(k(:));
y = conv2(y, k, 'same');

figure('color', 'k');
axis off equal
h = plotAnimatedSignal(chMap, y, fs, 'mode', 'color');


%% Plot traces of a 1D timeseries variable

figure('color', 'k');
axis off equal

h = probes.plots.plotAnimatedSignal(chMap, y, fs, ...
    'mode', 'trace', ...
    'frameLength', 0.5, ...
    'siteColor', 'k');

