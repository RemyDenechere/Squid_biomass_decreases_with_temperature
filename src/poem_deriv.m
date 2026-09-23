function dydt = poem_deriv(t, y, param)
% POEM_DERIV: ODE function for the POEM model
% This function will calculate the derivatives of the state variables dBdt,
% that will be used by the ODE solver to integrate the system over time.
% INPUTS:
%   t: time (not used in this function, but required by ODE solver)
%   y: vector of state variables (biomass of each size class and resource)
%   param: structure with model parameters
% OUTPUTS:
%   dydt: vector of derivatives of the state variables (required by the ode solver)


% EXTRACT VARIABLES FROM INPUTS:
y(y<0) = 0;                 % Ensure all values are non-negative
R = y(param.ixR);           % Extract resource biomass (zooplankton and benthic) from the state vector
B = y(param.ixFish);        % Extract fish biomass from the state vector


% CALCULATION OF ENCOUNTER RATE, PREDATION MORTALITY AND AVAILABLE ENERGY:
[~, mortpred, Eavail] = calcEncounter(y, param);

% DEFINE FISH INDEX: 
ixFish = param.ixFish;

% CALCULATION OF ALL TYPE OF MORTALITY : (predation + background + fishing)
mort = mortpred(ixFish)' + param.mort0 + param.F ;                

% FLUX OUT OF SIZE CLASS: 
v = (Eavail(param.ixFish))';  
vplus = max(0,v);                                                          % ensure that the growth rate is non-negative
gamma = (param.kappa'.*vplus - mort) ./ ...
    (1 - param.z(param.ixFish).^(1-mort./(param.kappa'.*vplus)) );         % biomass specific flux out of size class
Fout = gamma.*B;                                                           % Flux out of the size class 
Repro = (1-param.kappa').*vplus.*B;                                        % A fraction 1-k of the available energy is
                                                                           % invested in reproduction.                                                                
% Flux into the size group(where Fout in last stage stays is included in repro):
for i = 1:param.nSpecies
    ix = (param.ix1(i):param.ix2(i)) - length(R);                          % select Size class in Species
    ixPrev = [ix(end) ix(1:(end-1))];                                      % Index of the previous size class
    Fin(ix) = Fout(ixPrev);
    % Reproduction:
    Fin(ix(1)) = param.eRepro(i)*(Fin(ix(1)) + sum(Repro(ix)));            % The first size class receives the flux from the last size class
                                                                           %  and the reproduction flux from all size classes if it is the fisrt size class of the species.
end

% DERIVATIVE OF FISH BIOMASS:
dBdt = Fin' - Fout + (v - mort).*B - Repro ;  


% DERIVATIVE OF THE RESOURCE BIOMASS:
dRdt(1:2) = param.r(1:2)'.*(param.K(1:2)'-R(1:2)) - mortpred(1:2)'.*R(1:2);

% DETRITUS FLUX OUT OF RESOURCE 3 (BASED ON MARTIN ET AL. 2011): 
F_D_out = 121 + 2.58*(mortpred(param.ixR(1:2))*R(1:2));
dRdt(3) = F_D_out*param.martin*param.epst - param.r(3)'.*R(3) - mortpred(3)'.*R(3);
dRdt(4) = 0;

% ENCAPSULATE DERIVATIVES INTO A SINGLE VECTOR: 
dydt = [dRdt'; dBdt];

