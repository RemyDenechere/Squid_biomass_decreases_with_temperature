function param = baseparam_temp(param, region, temp)
% Base parameter for temperature. 
% param.region: 1=tropical, 2=temperate, 3=boreal, 4 = no temp scaling
if nargin <3
    temp = 10;
elseif nargin < 2
    region = 4; 
end 
param.region = region;
[param.scTemp, param.scTempm] = calctemperature(param, temp);

% Physio:
param.Cmax = param.scTemp .* (param.h.*param.wc.^param.n)./param.wc;
param.V = param.scTemp .* (param.gamma*param.wc.^param.q)./param.wc;
param.Mc = param.scTempm .* (param.met.*param.wc.^param.m)./param.wc;

end