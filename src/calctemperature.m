 function[scTemp, scTempm] = calctemperature(param, temp)
% calculate temperature dependencies integrating the vertical distribution
% Tempdata contain temperature per depth (from 0 to 5000m)
% the depth profile changes depending on the region: boreal, temperatre or tropical region. 

load('tempdata.mat');                % Load data                                                    
tempdata = table2array(tempdata);    % Convert table to array
tempdata(:,5) = temp;                % Create a non depth-scaling profile for the case of no temperature scaling (region = 4)
dist = (param.depthDay + param.depthNight)/2; % Average depth distribution

% Q10 CALCULATIONS:
TQ10 =  param.Q10.^((tempdata(1:param.bottom+1 , (param.region+1))-10)/10);
TQ10m =  param.Q10m.^((tempdata(1:param.bottom+1 , (param.region+1))-10)/10);

scTemp_step = dist .* TQ10;
scTemp = sum(scTemp_step, 1); 

scTemp_stepm = dist .* TQ10m;
scTempm = sum(scTemp_stepm,1);
 

