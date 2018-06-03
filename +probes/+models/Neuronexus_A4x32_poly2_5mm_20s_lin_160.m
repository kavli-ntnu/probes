classdef Neuronexus_A4x32_poly2_5mm_20s_lin_160 < probes.RegularMultiShankProbe
    
    methods
        function self = Neuronexus_A4x32_poly2_5mm_20s_lin_160()
            self.nShanks = 4;
            self.shankSpacing = 150;
        end
    end
    
    methods (Access = protected)
        
        function coords = onGetShankOutline(~)
            x = [-77 -77 -30 0 30 77 77]/2;
            y = [5000 325 35 0 35 325 5000];
            coords = [x' y'];
        end
        
        function coords = onGetShankSiteCoords(~)
            spc = 46;
            yOff = 50;
            x =  [ones(1, 15)*-1, ones(1, 15)]*17.32/2;
            y =  [45+20*(0:14), 35+20*(0:14)];
            coords = [x' y'];
        end
        
        function coords = onGetExtraSiteCoords(self)
            x = zeros(8, 1);
            y = [425 525 525 625 625 725 725 825]';
            coords = [x y];
        end
        
        function inds = onGetExtraSiteShankInds(self)
            inds = [1 1 2 2 3 3 4 4]';
        end
        
        function coords = onGetSiteOutline(self, idx)
            x = [-12 -12 12 12]/2;
            y = [-1 1 1 -1]*(13+1/3)/2;
            coords = [x' y'];
        end
        
        function inds = onGetChannelInds(~)
            % N.B. there is a mistake in the official channel map from
            % NeuroNexus! Channel #118 near bottom of shank #1 should be
            % channel #117. The indices below have been corrected.
            indsRegular = [ ...
                110 108 103 101 99 98 97 100 102 104 111 109 107 106 105 117 115 114 128 126 124 121 122 123 125 127 120 118 116 113 ...
                14 12 7 5 3 2 1 4 6 8 15 13 11 10 9 21 19 18 32 30 28 25 26 27 29 31 24 22 20 17 ...
                45 43 40 38 36 33 34 35 37 39 48 46 44 41 42 54 52 49 63 61 59 58 57 60 62 64 55 53 51 50 ...
                77 75 72 70 68 65 66 67 69 71 80 78 76 73 74 86 84 81 95 93 91 90 89 92 94 96 87 85 83 82];
            indsExtra = [112 119 16 23 47 56 79 88];
            inds = [indsRegular indsExtra]';
        end
        
        
    end
    
    
    
    
end

