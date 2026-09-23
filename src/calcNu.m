function [v, nu] = calcNu(Eavail, mort, param)
    % CALCULATION OF SOMATIC GROWTH RATE v FLUX TO NEXT SIZE CLASS nu
    % INPUTS:
    %  Eavail: available energy (g/m^2/yr) per size class
    %  mort: mortality (1/yr) per size class
    %  param: structure with model parameters
    % OUTPUTS:
    %   v: Available energy
    %   nu: parameter used for the calculation of growth flux to the next size class (based on de Ross discretisation method)
    % Originally written by P. Daniël Van Denderen, 
    % modified by Remy Denechere <remy.denechere@proton.me>


v = (Eavail(param.ixFish))';
vplus = max(0,v);
nu = (vplus - mort) ./ (1 - param.z(param.ixFish).^(1-mort./vplus) );