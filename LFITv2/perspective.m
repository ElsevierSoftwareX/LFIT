function [perspectiveImage] = perspective(radArray,u0,v0,SS_ST,sRange,tRange)
% perspective | Generates a perspective shift view at a (u,v) location

global sizePixelAperture; % (si*pixelPitch)/focLenMicro;

radArray = single(radArray);

% Define supersampling cases for clarity in code below
if SS_ST == 1
    SS = 'none';
end
if SS_ST ~= 1
    SS = 'st';
end
if round(u0) ~= u0 || round(v0) ~= v0 %ie, if u0 or v0 is not an integer. That's the only way you can really 'supersample' uv, and even so, it's really just interpolation...
    SS = 'both'; 
end

tRange = single(tRange);
sRange = single(sRange);
microRadius = single(floor(size(radArray,1)/2));

uRange = linspace(microRadius,-microRadius,1+(microRadius*2));
vRange(:,1) = linspace(microRadius,-microRadius,1+(microRadius*2));

sSSRange = linspace(sRange(1),sRange(end),(numel(sRange))*SS_ST);
tSSRange = linspace(tRange(1),tRange(end),(numel(tRange))*SS_ST); % negative sign fixes image flip. Since s goes from - to +, t apparently needs to as well

uIndex = -(u0) + microRadius+1; %u0 is negative since the uVector decreases from left to right (ie +7 to -7) while MATLAB image indexing increases from top to bottom
vIndex = -(v0) + microRadius+1; %v0 is negative since the vVector decreases from top to bottom (ie +7 to -7) while MATLAB image indexing increases from top to bottom

switch SS
    case {'none', 'st'}
        % st supersampling
        [t,s]=ndgrid(tRange,sRange);
        [tt,ss]=ndgrid(tSSRange,sSSRange);
        perspectiveImage=interpn(t,s,permute(radArray(uIndex,vIndex,:,:),[4,3,2,1]),tt,ss,'linear',0);
    case 'both'
        % uv supersampling (only makes sense in the case of evaluating the perspective at a non-integer value of u and v)
        % If you supersampled u,v in the traditional sense, it wouldn't make any sense since you're pulling a single u,v value from every s,t. It doesn't
        % matter how many u's and v's there are if you just use one, as is the case in perspective shifts.
        [tActual,sActual,vActual,uActual] = ndgrid(tRange,sRange,vRange.*single(sizePixelAperture),uRange.*single(sizePixelAperture)); %u,v to mm to match s,t which are in mm
        [tQuery, sQuery, vQuery, uQuery] = ndgrid(tSSRange,sSSRange,v0.*single(sizePixelAperture),u0.*single(sizePixelAperture));
        perspectiveImage = interpn(tActual,sActual,vActual,uActual,permute(radArray,[4,3,2,1]),tQuery,sQuery,vQuery,uQuery,'linear',0);
    otherwise
        error('The supersampling variable "SS_ST" in the perspective function was not set correctly.');
end

end

