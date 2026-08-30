
clear all
clf 
figsave = false;

save_dir = '../Fig/';
if ~exist(save_dir)
    mkdir save_dir
end 

%% Biomass vs Fishing on large pelagics or Demersals 
% Simulation fishing on potential squid predators: Demersal in shallow and
% Large pelagics in deeper regions. 
if exist("fig1")
    clf(fig1)
end

% set up range of parameters: ---------------------------------------------
depth = [50  2000];  % 250                                                
Zoo_prod = 100;
param = baseparameters();
param.Fi = [0.1, 0, 0.1, 0.1, 0.1];
FISHING = exp(linspace(log(0.1), log(3), 10));
Bi = zeros(10, param.nSpecies);
k = 0;

figure
t = tiledlayout(1, 2, TileSpacing="compact", Padding="compact");

for dp = 1:length(depth) % Loop depths
    param = baseparam_depth(param, depth(dp));

    k = k+1;
    param.K = [Zoo_prod  Zoo_prod  0  0];
    
        for j=1:length(FISHING)
    
            % size based fishing: 
            if dp == 1 % shallow region demersal as squid predator 
                param.Fi(4) = FISHING(j);
            else % large pelagics as squid predators
                param.Fi(3) = FISHING(j);
            end
    
            F = [];
            for fi = 1:param.nSpecies
                F = [F, param.Fi(fi) * (1+(param.wc(param.ix1(fi):param.ix2(fi))...
                    ./(param.wu(param.ix2(fi))*0.05)).^(-3)).^(-1)];
            end
            param.F = F';
            
            if j == 1 
                param.y0 = [0.1*param.K 0.01*param.B0];           
            else % start from previous final state. 
                param.y0 = results.y(end, :) + [0.1*param.K param.B0];
            end
    
            % no meso in shallow areas. 
            if depth(dp) < param.mesop
                param.y0(param.ix1(2):param.ix2(3))=0;        
            end
           
            % simulation: 
            results = poem(param);
            y = results.y; % biomass
            yend = y((end - 20):end,:);  % take values for the 40 last time steps
    
            % sum and average of biomass per species:
            for ii = 1:param.nSpecies 
                Bi(j, ii) =  sum(mean(yend(:, param.ix1(ii):param.ix2(ii))'));
            end
        end
        
        nexttile

        % plot Biomass per species  ---------------------------------------  
        Sp_plot = []; 
        hold on 
        for sp = [1, 3, 4, 5, 2]
            if sum(Bi(:, sp)) == 0 % if biomass = 0 don't plot the group. 
            else 
                % Biomass: ------------------------------------------------
                Sp_plot = [Sp_plot, sp];
                plot(FISHING, Bi(:, sp)' , '-',  'LineWidth', param.LWidth(sp),...
                'color', param.Color(sp, :))
            end 
        end
        
        if dp == 1 
            title('A. Shelf system')
            xlabel('Fishing on demersal (yr^{-1})')
        else 
            xlabel('Fishing on large pelagic (yr^{-1})')
            title('B. Open Ocean')
            legend(param.SpId{Sp_plot},'Location','best', ...
                'Box','off', 'Color', 'none', 'EdgeColor', 'none')
        end
        set(gca, 'FontSize', 11);
end
ylabel(t, 'Biomass (g WW m ^{-2})')
 
if figsave
    save_graph(gcf, 'pdf', 'FigurePaper3/Fishing_on_Lpel', 16, 10)
end 

%% Squid diet and mortality in OPEN OCEAN under high and low fishing 
if exist("fig2")
    clf(fig2)
end

fig2 = figure();

t = tiledlayout(2, 3, "TileSpacing", "loose", "Padding", "compact");
% title(t, 'Effect of Large pelagic fishing on squid in the Open Ocean')

% set up range of parameters: ---------------------------------------------
depth = 2000;                                   % Depth in m                                           
Zoo_prod = 100;                                 % Zooplankton production (g ww m-2 yr -1)           
param = baseparameters();                       % Create parameter structure
param = baseparam_depth(param, depth);          % Create depth related parameters
param.K = [Zoo_prod  Zoo_prod  0  0];           % Define productivity for each resouce (based on van Denderen 2021)

%! Calculation at low fishing intensity : ----------------------------------
% Calculate size-based fishing: 
param.Fi = [0.1, 0, 0.1, 0.1, 0.1];             % Fishing intensity for each group with a constant fishing
F = [];
for fi = 1:param.nSpecies
    F = [F, param.Fi(fi) * (1+(param.wc(param.ix1(fi):param.ix2(fi))...
        ./(param.wu(param.ix2(fi))*0.05)).^(-3)).^(-1)];
end
param.F = F';

% Define Initial Conditions 
param.y0 = [0.1*param.K 0.01*param.B0]; 
if depth < param.mesop % no meso in shallow areas. 
    param.y0(param.ix1(2):param.ix2(3))=0;        
end
results = poem(param);

% Plot Panel A: Low fishing feeding level
nexttile
plotdiet_squid(param, results, true)
ylabel('Fraction in stomach')
xlabel('Size-class ')
title('A. Low fishing')
set(gca, 'FontSize', 11)
nexttile(4, [1, 3])
plotmort_squid(param, results, '-')
title('C. Effect of large pelagic fishing on squid mortality')

%! Calculation at low fishing intensity : ----------------------------------
depth = 2000;  % 250                                                
Zoo_prod = 100;
param = baseparameters();
param = baseparam_depth(param, depth);
param.K = [Zoo_prod  Zoo_prod  0  0];

% Calculate size-based fishing: 
param.Fi = [0.1, 0, 3, 0.1, 0.1];
F = [];
for fi = 1:param.nSpecies
    F = [F, param.Fi(fi) * (1+(param.wc(param.ix1(fi):param.ix2(fi))...
        ./(param.wu(param.ix2(fi))*0.05)).^(-3)).^(-1)];
end
param.F = F';

% Define Initial Conditions 
param.y0 = [0.1*param.K 0.01*param.B0]; 
if depth < param.mesop % no meso in shallow areas. 
    param.y0(param.ix1(2):param.ix2(3))=0;        
end
results = poem(param);

% Plot Panel B: feeding level at high fishing intensity
nexttile(2)
plotdiet_squid(param, results, false)
xlabel('Size-class')
title('B. High fishing')
set(gca, 'FontSize', 11)

% Plot Panel B: Squid mortality at high fishing intensity
nexttile(4, [1, 3])
plotmort_squid(param, results, '--')
xlabel('Individual mass (g)')
leg = legend('low', 'High'); 
title(leg, 'Fishing on Large pelagic')
set(gca, 'FontSize', 11)

%! Save figure
if figsave
    save_graph(fig2, 'pdf', [save_dir 'F_mort_squid_Deep'], 16, 10)
end