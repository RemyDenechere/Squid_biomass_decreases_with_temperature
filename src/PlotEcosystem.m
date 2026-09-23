function PlotEcosystem(depth, pprod, sqd)
    % Building app for Matlab app builder. The function first run the FEISTY
    % model, then produce a plot for ecosystem. 
    % INPUT VARIABLES:
    %   1) depth: depth of the ecosystem (m)
    %   2) pprod: primary productivity (g ww/m2)
    %   3) sqd: presence (0) or absence (1) of squids in the ecosystem
    % remy Denechere <remy.denechere@proton.me>
    % see also van Denderen et al. 2020
    arguments 
        depth {mustBeNumeric} = 750
        pprod {mustBeNumeric} = 130
        sqd {mustBeMember(sqd, [0, 1])} = 0
    end
%% GLOBAL PARAMETERS:
Ftsize = 11;      % Font size for the plot

%
%% Run FEISTY: 

% FEISTY PARAMETER DEFINITION:
param = baseparameters();                           % base parameters for the model
param = baseparam_depth(param, depth);              % define the parameters for the depth of the ecosystem
param.K =  [pprod, pprod, 0, 0];                    % zoo plankton production (g ww/m2)
param.y0 = [0.1*param.K 0.01*param.B0];             % Initial conditions for the model (biomass)

% ABSENCE OF MESOPELAGICS IN SHALLOW ECOSYSTEMS:
if depth < param.mesop
    param.y0(param.ix1(2):param.ix2(2))=0; % mesopelagics to zero
end

% REMOVE OR ADD SQUIDS IN THE ECOSYSTEM:
if sqd == 1 
    param.y0(param.ix1(5):param.ix2(5)) = 0;
end

ngroup = param.ix2(end);                            % Get the number of functional group

% RUN FEISTY-Squid: 
result = poem(param);                               % Model run

% AVERAGED BIOMASS:                                                     
Bi = mean(result.y((end - 40):end,:)); % take values for the 40 last time steps

% CALCULATE FLUXES OF DETRITUS REACHING THE BENTHIC LAYER USING A MARTIN CURVE:
[~, mortpred, ~] = calcEncounter(Bi, param); 
F2B = (121 + 2.58*mortpred(1:2).*Bi(1:2))*param.martin*param.epst - param.r(3)'.*Bi(3) - mortpred(3)'.*Bi(3);

%% Parameters for plot
%
% CALCULATE AVERAGE DEPTH OF EACH FUNCTIONAL GROUP:
Av_depth = -(param.avlocDay + param.avlocNight)/2;

% ADJUSTMENT OF DEPTH FOR VISUALISATION PURPOSES: (to avoid overlapping of points in the plot) 
Av_depth(param.ix1(1):param.ix2(1)) = Av_depth(param.ix1(1):param.ix2(1))+0.1*param.bottom;
Av_depth(param.ix1(3):param.ix2(3)) = Av_depth(param.ix1(3):param.ix2(3))-0.1*param.bottom;
if param.bottom < param.mesop
    Av_depth(param.ix1(5):param.ix2(5)) = Av_depth(param.ix1(5):param.ix2(5))+0.05*param.bottom;
    Av_depth(param.ix1(4):param.ix2(4)) = Av_depth(param.ix1(4):param.ix2(4))-0.05*param.bottom;
else 
    Av_depth((param.ix1(4)+3):param.ix2(4)) = Av_depth((param.ix1(4)+3):param.ix2(4));
    Av_depth(param.ixR(3)) = Av_depth(param.ixR(3));
end 

% Marker size depends on biomass:--------------------------------------
Msize = Bi;
Msize(Msize == 0) = nan;
Msize = log(Msize+1.01)*150;            % Scale the marker size based on biomass with a logarithmic transformation

% MATRIX OF PREDATION FLUXES BETWEEN SIZES:------------------------------------------------
% CREATE COORDINATES: 
coord_y = []; 
coord_x = [];
idx = [];
for i = 1:ngroup
        idx(1,1:ngroup) = param.wc(1:ngroup);
        idx(2,1:ngroup) = param.wc(i);
        coord_x = [coord_x, idx];    
    
        idx(1,1:ngroup) = Av_depth(1:ngroup);
        idx(2,1:ngroup) = Av_depth(i);
        coord_y = [coord_y, idx];
end 

% DEFINE LINEWIDTH BASED ON FLUXES INTENSITY : ----------------------------------------------------
Theta = param.theta .* Bi .* Bi';                       % flux equal the rate * the prey biomass (* 0 if pred = 0)
Theta(3,1:2) = F2B;
Theta = Theta(1:end); 
Values = sort(Theta); 
indx = find(Theta > Values(end-60));                    % takes the x highest values of theta
idxL = quantile(Theta(indx), [0.33, 0.66]);             % Get quantiles of Theta distribution.  

% DEFINE LINEWIDTH CATEGORIES BASED ON FLUXES INTENSITY : ----------------------------------------------------
LineWdth = Theta;                                       % give the appropriate size
LineWdth(Theta >= idxL(2)) = 1.8;
LineWdth(Theta < idxL(2) & LineWdth >= idxL(1)) = 0.9;
LineWdth(Theta < idxL(1)) = 0.45;

% DEFINE LINE STYLE BASED ON FLUXES INTENSITY : ----------------------------------------------------
Linetype(Theta >= idxL(2)) = {'-'};
Linetype(Theta < idxL(2) & LineWdth >= idxL(1)) = {'--'};
Linetype(Theta < idxL(1)) = {':'};

% SET UP COLORS FOR EACH FUNCTIONAL GROUP   :--------------------------------------------------------
colorSet = zeros(ngroup, 3);
colorSet(1:4,:) =  [0      0.5      0;
                0.62   0.99     0.51; 
                0.5    0.3      0;
                0.5    0.3      0;];         

for i = 1:param.nSpecies
    for j = param.ix1(i):param.ix2(i)
        colorSet(j, :) = param.Color(i,:);
    end
end 

Col = [];
for i = 1:ngroup
    for j = 1:ngroup
    Col = [Col; colorSet(i,:)];
    end 
end 

% DRAWINF A SCATER PLOT OF THE FLUXES BETWEEN FUNCTIONAL GROUPS:-------------------------------------------------------- 
x = coord_x(:,indx);
y = coord_y(:,indx);

p = plot(coord_x(:,indx) , coord_y(:,indx), 'k');
for i = 1:length(x)
    p(i).LineWidth = LineWdth(indx(i));
    p(i).Color = Col(indx(i), : );
    p(i).LineStyle = Linetype{indx(i)};
end 

hold on 
scatter(param.wc, Av_depth, Msize, colorSet, 'filled')

% ADDITIONAL PLOT SETTINGS:-------------------------------------------------------- 
set(gca,'BoxStyle','full','Color',...
'none' ,'FontSize', Ftsize,'GridLineStyle',...
'none','XMinorTick','on','XScale','log',... 
'Ylim', [-1.10*param.bottom, max(Av_depth)+0.1*param.bottom], ...
'Xlim', [10^(-5) 10^5], 'XTick', [10^(-3) 10^(1) 10^(5)], ...
'YTick', [-param.bottom 0]);

% ADJUSTEMENT OF YLIM FOR OPEN OCEAN ECOSYSTEM :
if param.bottom > param.mesop
    set(gca, 'Ylim', [-(1.05*param.bottom), max(Av_depth)+0.05*param.bottom], ...
    'YTick', [-(param.bottom) 0], 'YTickLabel', [-param.bottom 0])
end
