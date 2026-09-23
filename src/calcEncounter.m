function [f, mortpred, Eavail, Enc] = calcEncounter(y, param)
% CALCULATION OF ENCOUNTER RATE, PREDATION MORTALITY AND AVAILABLE ENERGY
% INPUTS:
%  y: vector of biomass (g/m^2) per size class
%  param: structure with model parameters
% OUTPUTS:
%   f: feeding level (0-1) per size class
%   mortpred: predation mortality (1/yr) per size class
%   Eavail: available energy (g/m^2/yr) per size class
%   Enc: encounter rate (1/yr) per size class
% Originally written by P. Daniël Van Denderen, modified by Remy Denechere <remy.denechere@proton.me>

% ENCOUNTER RATE (CLEARANCE RATE * PREFERENCE * BIOMASS OF PREY):
Enc = param.V' .* param.theta.*y';

% FEEDING LEVEL: ----------------------------------------------------------
Encspecies = sum(Enc');                                 % sum per functional group
f = Encspecies./(param.Cmax+Encspecies);                % correction for total prey consumption 
f(isnan(f)) = 0;                                        % set NaN values to 0
Eavail = param.Cmax.*param.epsAssim.*f - param.Mc;      % Claculate available energy (g/m^2/yr) per size class

% MORTALITY: from prey on i
mortpr =  ((param.Cmax .* param.V)' .* param.theta./ (param.Cmax + Encspecies)') .* y;
mortpred = sum(mortpr);  
