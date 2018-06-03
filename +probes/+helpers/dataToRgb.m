function [RGB] = dataToRgb(x, clims, colmap, n)
%DATATORGB map data in array onto a specified RGB colormap
%
%   INPUTS
%   x - vector containing data to be colour-mapped
%   clims - two-element vector defining colormap limits in terms of x
%   (optional, default uses [min(x) max(x)])
%   colmap - string defining colormap to be used (optional, default
%   'jet')
%   n - number of discrete values of colormap
%   
%   OUTPUTS
%   RGB - array of color-mapped RGB values, with the 3 RGB channels
%   occupying the last dimension.
% 
% N.B. if a figure is not open then calling this function will open one.

if nargin < 4 || isempty(n), n = 256; end

if isrow(x)
    x = x';
end

sz = size(x);
nDim = find(sz>1,1,'last');

if nargin<3
    cmap=jet(n);
elseif ischar(colmap)
    cmap = feval(colmap,n);
elseif size(colmap,2) == 3
    cmap = colmap;         % If colormap matrix given instead
else
    error('Incorrect format for colormap')
end

if nargin<2 || isempty(clims)
    clims=[min(x(:)) max(x(:))];
elseif clims(1)==clims(2)
        error('Supplied clims must be non-equal and ascending')
end

% Scale x values from clim(1) to clim(2) over range 0-1
x_scaled = (x-clims(1))/(clims(2)-clims(1));
% Set all values that are off the scale to the most extreme color values
x_scaled(x_scaled<0) = 0;
x_scaled(x_scaled>1) = 1;

% Re-scale to match dimensions of colormap
x_scaled=ceil(x_scaled.*(size(cmap,1)-1))+1;

% Now generate RGB values (leave NaN values as they are);
valid=~isnan(x_scaled(:));

RGB = zeros(prod(sz),3);

% Reshape into a 3-col RGB matrix with one row for each element of x
RGB(valid,:)=cmap(x_scaled(valid),:);
RGB(~valid,:)=NaN;

% Reshape x back into its original form
if nDim > 1
    RGB = reshape(RGB,[sz 3]);
end

end

