function m = createKilosortChannelMap(chMap)
% Export Kilosort-format channel map
coords = chMap.probe.getSitePositions();
m.xcoords = coords(:, 1);
m.ycoords = coords(:, 2);
m.chanMap = double(chMap.siteInds);
m.chanMap0ind = m.chanMap-1;
m.shankInd = double(chMap.probe.getSiteShankInds());
m.connected = chMap.enabled;
end