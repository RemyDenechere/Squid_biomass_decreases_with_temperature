function plotdiet_squid(param, result, leg)
w = param.wc;
y = result.y;

Bin = floor(0.8*length(y));
yend = mean(y(Bin:end,:));
ystage = param.ixFish(end);
ysmall = param.nstage - param.nstage*2/3;

[f, ~, ~, ~] = calcEncounter(yend', param);

bom = param.theta(5:ystage,:) .* mean(y(Bin:end,:)); 
fbom = f(5:ystage)' ./ sum(bom,2);
output = bom .* fbom;

colspec = [1 1 2 2 repmat(3,param.nstage*2/3,1)' ...
           repmat(4,param.nstage*2/3,1)'         ...
           repmat(5,param.nstage,1)'             ...
           repmat(6,param.nstage,1)'             ...
           repmat(7,param.nstage,1)'];
       
colorSet =  [0      0.5      0;
             0.5    0.3      0;
             param.Color];
 

% Squid: ------------------------------------------------------------------ 
    small_Ceph = output(param.ix1(5)-4:param.ix2(5)-4,:);
    small_Ceph = [small_Ceph; zeros(ysmall, ystage)];
    H = bar(small_Ceph, 'stacked');
     for i = 1:ystage
         H(i).FaceColor = colorSet(colspec(i),:);
         H(i).LineStyle = 'none';
     end
    ylim([0 1])    
    set(gca,'XTick',[], 'FontSize', 11)
    xlabel('size-classes')


% plot legend
if leg
    legend(H([1 3 param.ix1]),{'Zoopl','Benthos', param.SpId{1:end}}, ...
        'Position',[0.708522075493149 0.600576583981934 0.207341272774197 0.329281191341973], ...
        'Box','off', 'EdgeColor', 'none', 'Color', 'none')
end 
