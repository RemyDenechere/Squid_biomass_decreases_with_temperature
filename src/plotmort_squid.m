function  plotmort_squid(param, result, linest)
% PLOT THE MORTALITY OF SQUID (STACKED BAR PLOT)
% INPUTS: 
%  param: structure with model parameters
%  result: structure with model outputs
%  linest : The Line type for the plot (e.g. '-', '--', ':', '-.')
%  Remy Denechere <remy.denechere@proton.me>
%  Based upon P. Daniël Van Denderen's work 
arguments
    param struct        
    result struct
    linest string{mustBeMember(linest, {'-', '--', ':', '-.'})} = '-'
end

% EXTRACT SIMULATED VARIABLES FROM RESULT STRUCTURES:
y = result.y;
R = result.R;
B = result.B;
t = result.t;

% CALCULATION OF PREDATION MORTALITY:
xlimit = [min(param.wc(param.ixFish))/10 max(param.wu)];        % X-axis limits (size)
Bin = floor(0.8*length(y));                                     % Index of the last 20% of the last time step 
yend = mean(y(Bin:end,:));                                      % average biomass of the last 20% of the last time steps
[f, mortpred] = calcEncounter(yend', param);                    % Calculates the encounter rate between all size classes and the predation mortality for each size class
wc = param.wc;                                                  % central weight (g)

% Change the legend depending on the presence or absence of mesopelagic.
if param.bottom < param.mesop
    param.SpId = param.SpId([1,2,4,5]);
end

% PLOT OF PREDATION MORTALITY: ----------------------------------------------------
hold on
for ii = 5
plot(param.wc(param.ix1(ii):param.ix2(ii)), mortpred(end,param.ix1(ii):param.ix2(ii)),...
    'linewidth', param.LWidth(ii), 'Color', param.Color(ii,:), 'LineStyle', linest)
end

ylim([0 1.2*max(mortpred)])
xlim(xlimit)
ylabel('Predation mort.')
xlabel('central weight (grams)')
set(gca, 'FontSize', 11, 'Xscale', 'log', 'Box', 'on')
hold off




