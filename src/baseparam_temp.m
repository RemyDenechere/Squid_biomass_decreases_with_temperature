function param = baseparam_temp(param, region, temp)
% CALCULATE TEMPERATURE SCALING FACTORS FOR THE PHYSIOLOGICAL PARAMETERS
% AND RECALCULATE THE PHYSIOLOGICAL PARAMETERS THAT DEPEND ON TEMPERATURE
% param.region: 1=tropical, 2=temperate, 3=boreal, 4 = no temp scaling
if nargin <3 % IF no temperature is specified, use default temperature of 10 degrees C
    temp = 10; 
elseif nargin < 2 % If no region is specified, use default region 4 (no temperature scaling)
    region = 4; 
end 

% CALCULATE TEMPERATURE SCALING FACTORS FOR THE PHYSIOLOGICAL PARAMETERS:
param.region = region;
[param.scTemp, param.scTempm] = calctemperature(param, temp);

% RECALCULATE PHYSIOLOGICAL PARAMETERS THAT DEPEND ON TEMPERATURE 
param.Cmax = param.scTemp .* (param.h.*param.wc.^param.n)./param.wc;
param.V = param.scTemp .* (param.gamma*param.wc.^param.q)./param.wc;
param.Mc = param.scTempm .* (param.met.*param.wc.^param.m)./param.wc;

end