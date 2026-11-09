function param = baseparam_depth(param, depth)
% Sets parameters relating to depth: 
% Marting curve, feeding preference matrix based on day and night vertical 
% distribution
% -------------------------------------------------------------------------
%
% Habitat and interactions: -----------------------------------------------
%
param.bottom = depth; % depth in meter
param.xrange = linspace(0, param.bottom, (param.bottom + 1)); % depths range
param.martin = min((param.bottom./param.photic).^(-0.86), 1); % martin curve depth
[param.theta, param.depthDay, param.depthNight, param.avlocDay, param.avlocNight] = calcpreference(param); % feeding preference matrix 

%
% Default initial conditions: ---------------------------------------------
% 
param.r =  [1  1  1  0]; % [K(1) K(2) 1 0]; %  g ww/m2/yr (here should be in per year). 


end