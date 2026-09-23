function plotdiet_squid(param, result, leg)
% PLOT THE DIET OF SQUID (STACKED BAR PLOT)
% INPUTS: 
%  param: structure with model parameters
%  result: structure with model outputs
%  leg : logical, if true plot legend, if false do not plot legend
%  Remy Denechere <remy.denechere@proton.me>
%  Based upon P. Daniël Van Denderen's work 
    arguments
        param struct        
        result struct
        leg logical = true
    end

% GET BASIC VARIABLES:
w = param.wc;                                           % central weight (g)
y = result.y;                                           % biomass (g/m^2) per size class

Bin = floor(0.8*length(y));                             % index of the last 20% of last time steps
yend = mean(y(Bin:end,:));                              % mean biomass of the last 20% of last time steps
ystage = param.ixFish(end);                             % number of size classes
ysmall = param.nstage - param.nstage*2/3;               % number of juvenile size classes
% index of the first size class of the small squid

[f, ~, ~, ~] = calcEncounter(yend', param);             % Calculs encounter rater between all size classes 

% CALCULATE PREDATION MORTALITY 
bom = param.theta(5:ystage,:) .* mean(y(Bin:end,:));    % Biomass preference: size preference matrix * biomass
fbom = f(5:ystage)' ./ sum(bom,2);                      % normalized feeding level with respect to the total biomass preference (to get output between 0 and 1)
output = bom .* fbom;                                   % final output: normalized feeding level * biomass preference per size class
                                                        % !! Note that the thetha and f start at 5th values because the first 4 values are for the resources (zooplankton and benthic)
%! DEFINE COLOR SPECIFICATION FOR THE STACKED BAR PLOT: 
% INDEX:
colspec = [1 1 2 2 repmat(3,param.nstage*2/3,1)' ...
           repmat(4,param.nstage*2/3,1)'         ...
           repmat(5,param.nstage,1)'             ...
           repmat(6,param.nstage,1)'             ...
           repmat(7,param.nstage,1)'];
% COLOR:
colorSet =  [0      0.5      0;
             0.5    0.3      0;
             param.Color];
 

% ! PLOT STACKED BAR PLOT OF THE DIET OF SQUID:
    small_Ceph = output(param.ix1(5)-4:param.ix2(5)-4,:);       % output for squid only ('-4' adjusts the index to account for the resource  )
    H = bar(small_Ceph, 'stacked');                             % Plot on top of each other the different prey for a size class 
     for i = 1:ystage
         H(i).FaceColor = colorSet(colspec(i),:);
         H(i).LineStyle = 'none';
     end
    ylim([0 1])    
    set(gca,'XTick',[], 'FontSize', 11)
    xlabel('size-classes')


% PLOT LEGEND: 
if leg
    legend(H([1 3 param.ix1]),{'Zoopl','Benthos', param.SpId{1:end}}, ...
        'Position',[0.708522075493149 0.600576583981934 0.207341272774197 0.329281191341973], ...
        'Box','off', 'EdgeColor', 'none', 'Color', 'none')
end 
