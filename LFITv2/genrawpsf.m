function [outputPSF] = genrawpsf(microDiameterExact,psfFlag)
% genrawpsf | Generates a raw, unpadded PSF to be used in refocusing
%
%  microDiameterExact: exact diameter of a microlens in pixels
%
%  psfFlag: 0 = reserved
%           1 = disk (ceiling, ie all ones)
%           2 = disk (sums to 1)
%           3 = disk (normalized to max of 1)
%           
%
%  Author: Jeffrey Bolan | 9/19/14

microRadius = (microDiameterExact/2) - 1;

switch psfFlag
    case 0
        % do nothing  
    case 1
        % disk, forced to all ones
        flatPSF = fspecial('disk', microRadius);
        flatPSF(flatPSF>0) = 1;
    case 2
        % intensities sum to 1
        flatPSF = fspecial('disk', microRadius);
    case 3
        % normalized to a max of 1
        flatPSF = fspecial('disk', microRadius);
        flatPSF = flatPSF./max(max(flatPSF));
    otherwise
        error('Invalid psfFlag passed to genpsf.m');
end

outputPSF = flatPSF; % note that this will need to be padded to match the experimental focal stack dimensions.


end
