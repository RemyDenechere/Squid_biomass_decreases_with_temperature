function  plotmort_squid(param, result, linest)

y = result.y;
R = result.R;
B = result.B;
t = result.t;

xlimit = [min(param.wc(param.ixFish))/10 max(param.wu)];
Bin = floor(0.8*length(y));
yend = mean(y(Bin:end,:));
[f, mortpred] = calcEncounter(yend', param);
wc = param.wc;

% Change the legend depending on the presence or absence of mesopelagic.
if param.bottom < param.mesop
    param.SpId = param.SpId([1,2,4,5]);
end

% Predation Mortality: ----------------------------------------------------
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




