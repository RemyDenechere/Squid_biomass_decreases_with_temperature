%% Squid biomass increase is not explain by rising temperature but rather loss of top predators.
% This script generates the figures for the paper: 
% "Squid biomass increase is not explain by rising temperature but rather loss of top predators."
%  - FigEco: Ecosystem structure
%  - FigEa:  Effect of temperature on Available Energy
%  - Fig 1:  Effect of fishing on squid and their predators
%  - Fig 2:  Effect of large pelagic fishing on squid feeding level and mortality in the open ocean
%  - Fig 3:  Effect of temperature on Available Energy
% 
% Remy Denechere <remy.denechere@proton.me>
% Based upon P. Daniël Van Denderen's work 

%% Initialization 
clear all 
clf 

% CREATE FIGURE DIRECTORY IF NOT EXISTING
save_dir = '../Fig/';       % path to save figures
if ~exist(save_dir)         % check if the directory exists
    mkdir(save_dir)         % create the directory if it does not exist
end 

figsave = true;             % Set to true to save figures   


%% Ecosystem plot: 
% Plot the ecosystem structure emerging from FEISTY-Squid
% ----------------------------------------------------------------%

% CLEAR EXISTING FIGURE:
if exist("FigEco")
    clear FigEco
end

FigEco = figure();

% PLOT ECOSYSTEM STRUCTURE:
PlotEcosystem(750, 130, 0) % Function to plot the ecosystem structure (depth, productivity, Squid presence (0)/absance (1))
if figsave
    save_graph(FigEco, 'pdf', [save_dir 'Ecosystem_plots'], 17, 16)
end 

%% Effect of temperature on Available Energy 
% 
% Here I run a sensitivity analysis of the FEISTY-squid equations that relates to temperature: 
% Maximum consumption rate (Cmax), ingestion rate (V), metabolic cost (Mc) and the resulting available energy (Ea)
% for varying temperatures (0--50°C) and at 3 resource levels,
% in order to assess how individual bioenergetic changes with temperature for different productivity.
% ----------------------------------------------------------------%

% CLEAR EXISTING FIGURE:
if exist("figEa")
    clear figEa
end

% PARAMETER SET : ---------------------------------------------------------
param = baseparameters();                                               % Base parameters for the model
T= linspace(0, 50, 50);                                                 % Temperature range (°C)
R = 10.^([-2, -0.25, 1]) ;                                              % Resource abundance (g) for the 3 different scenarios

Cmax = param.Q10(1).^((T-10)/10)*param.h(1)*param.sizes(5)^-0.25;        % Maximum consumption rate (Cmax) 
V = param.Q10(1).^((T-10)/10)*param.gamma*param.sizes(5)^-0.25;          % Ingestion rate (V)
Mc = param.Q10(1).^((T-10)/10)*param.met(1)*param.sizes(5)^-0.25;        % Metabolic cost (Mc)
Ea = param.epsAssim * Cmax.*(V.*R'./(V.*R' + Cmax)) - Mc;                % Available energy (Ea)

figEa = figure();

% PLOT : ---------------------------------------------------------
plot(T, Ea, 'LineWidth', 1.5)
hold on 
plot(T, Mc, 'k--','LineWidth', 1.5)
legend('R = 10^{-2} g', 'R = 10^{-0.25} g', 'R = 10^{1} g', ... 
        'Metabolic cost', 'Location','northwest', ...
        'Box','off', 'Color', 'none', 'EdgeColor', 'none')
set(gca, 'FontSize', 11);

% ADD  TEXT AND ARROW TO SHOW THE EFFECT OF TEMPERATURE ON AVAILABLE ENERGY:
annotation("textarrow", [0.7442 0.7379], [0.7276 0.2867], "String", "")
annotation("textbox", [0.5424 0.3704 0.3473 0.06983], "String", "food scattering")
hTextboxshape = findall(figEa,"Type","textboxshape");
hTextboxshape.EdgeColor = "none";
hTextboxshape.BackgroundColor = [1,1,1];
hTextboxshape.HorizontalAlignment = "center";

% SET LABELS 
xlabel('Temperature °C')
ylabel('Available Energy (E_a)')
set(gca, 'FontSize', 11);

% SAVE FIGURE
if figsave
    save_graph(figEa, 'pdf', [save_dir 'Ea_vs_T'], 8, 8)
end 

%% Biomass over Fishing on large pelagics (open ocean) or Demersals (shelf system)
% We simulated fishing on potential squid predators: Demersal in shallow systems and
% Large pelagics in deeper regions. 
% 
% ----------------------------------------------------------------------------------%

% CLEAR EXISTING FIGURE:
if exist("fig1")
    clear fig1
end

% PARAMETER SET : ---------------------------------------------------------
depth = [50  2000];                             % Depth in m                                              
Zoo_prod = 100;                                 % Zooplankton production (g ww m-2 yr -1)
param = baseparameters();                       % Create parameter structure
param.K = [Zoo_prod  Zoo_prod  0  0];           % Define productivity for each resouce (based on van Denderen 2021)
param.Fi = [0.1, 0, 0.1, 0.1, 0.1];             % Fishing intensity for each group with a constant fishing
FISHING = exp(linspace(log(0.2), log(3), 10));  % Define the variation of fishing intensity for large predators 
Bi = zeros(10, param.nSpecies);                 % Storage variable biomass 
k = 0;                                          % counting variable

fig1 = figure();                                % plot in figure 1

% CREATE TILED LAYOUT FOR PANEL PLOT:
t = tiledlayout(1, 2, TileSpacing="compact", Padding="compact");

% SIMULATIONS :-------------------------------------------------------------
for dp = 1:length(depth) % Loop depths
    param = baseparam_depth(param, depth(dp));  % Set up depth related parameters 
    k = k+1;                                    % add to count

        for j=1:length(FISHING) % Loop fishing 
    
            % DEFINE FISHING EFFORT FOR EACH FUNCTIONAL GROUP :------------
            if dp == 1 % shallow region demersal as squid predator 
                param.Fi(4) = FISHING(j);
            else % large pelagics as squid predators
                param.Fi(3) = FISHING(j);
            end
    
            % CALCULATION OF FISHING MORTALITY: ----------------------------
            F = [];
            for fi = 1:param.nSpecies
                % FISHING MORTALITY EQUATION
                F = [F, param.Fi(fi) * (1+(param.wc(param.ix1(fi):param.ix2(fi))...
                    ./(param.wu(param.ix2(fi))*0.05)).^(-3)).^(-1)];
            end
            param.F = F';
            
            % INITIAL CONDITIONS: ------------------------------------------
            if j == 1 % Define initial condition for 1st simulation 
                param.y0 = [0.1*param.K 0.01*param.B0];           
            else % start from previous final state for later simulation 
                param.y0 = results.y(end, :) + [0.1*param.K param.B0];
            end
    
            % REMOVE MESOPELAGIC FISH IN SHALLOW ARREAS --------------------
            if depth(dp) < param.mesop
                param.y0(param.ix1(2):param.ix2(3))=0;        
            end
           
            % CORE SIMULATION OF FEISTY-squid: 
            results = poem(param);
            y = results.y;                  % Extract biomass
            yend = y((end - 30):end,:);     % Take last 40 time steps
    
            % sum and average of biomass per species: ----------------------
            for ii = 1:param.nSpecies 
                Bi(j, ii) =  sum(mean(yend(:, param.ix1(ii):param.ix2(ii))'));
            end
        end % end loop fishing 
        
        nexttile

        % PLOT BIOMASS PER FUNCTIONAL GROUP: -------------------------------
        Sp_plot = [];                       % Define index of functional group (sp) to plot 
        hold on 
        for sp = [1, 3, 4, 5, 2]            % change the order for legend
            if sum(Bi(:, sp)) == 0          % if biomass = 0 don't plot the functional group. 
            else 
                Sp_plot = [Sp_plot, sp];    % Keep track of the functional group plotted
                plot(FISHING, Bi(:, sp)', ...
                    '-',  'LineWidth', param.LWidth(sp),...
                    'color', param.Color(sp, :))
            end 
        end
        % PLOT TOTAL BIOMASS IN THE SYSTEM:
        plot(FISHING, sum(Bi, 2) , 'k--',  'LineWidth', param.LWidth(3))
        hold off 
        
        % DEPTH DEPENDENT LABELING: ----------------------------------------
        if dp == 1 
            title('A. Shelf system')
            xlabel('Fishing on demersal (yr^{-1})')
        else 
            xlabel('Fishing on large pelagic (yr^{-1})')
            title('B. Open Ocean')
            legend({param.SpId{Sp_plot}, 'Total'}, ... % Put in legend only the functional group plotted
                'Location','best', ...
                'Box','off', 'Color', 'none', 'EdgeColor', 'none')
        end
        set(gca, 'FontSize', 11); % Modify the font size of the figure 
end % end loop depth 

ylabel(t, 'Biomass (g WW m ^{-2})')

% SAVE FIGURE INTO FIG/
if figsave
    save_graph(fig1, 'pdf', [save_dir 'Fishing_Predatory_fish'], 16, 8)
end 

%
%% Effect of large pelagic fishing on squid feeding level and mortality in the open ocean
% 
% ---------------------------------------------------------------------------------------%% 

% CLEAR EXISTING FIGURE:
if exist("fig2")
    clear fig2
end
fig2 = figure();                               % Define figure variable

% CREATE TILED LAYOUT FOR PANEL PLOT:
tiledlayout(2, 3, "TileSpacing", "loose", "Padding", "compact");

% PARAMETER SET : ---------------------------------------------------------
depth = 2000;                                   % Depth in m                                           
Zoo_prod = 100;                                 % Zooplankton production (g ww m-2 yr -1)           
param = baseparameters();                       % Create parameter structure
param = baseparam_depth(param, depth);          % Create depth related parameters
param.K = [Zoo_prod  Zoo_prod  0  0];           % Define productivity for each resouce (based on van Denderen 2021)

% CALCULATION OF FISHING MORTALITY: ----------------------------
% USING LOW FISHING INTENSITY OF 0.1 yr-1 FOR EACH FUNCTIONAL GROUP
param.Fi = [0.1, 0, 0.1, 0.1, 0.1];             % Fishing effort for each group with a constant fishing
F = [];
for fi = 1:param.nSpecies
    % FISHING MORTALITY EQUATION
    F = [F, param.Fi(fi) * (1+(param.wc(param.ix1(fi):param.ix2(fi))...
        ./(param.wu(param.ix2(fi))*0.05)).^(-3)).^(-1)];
end
param.F = F';                                   

% INITIAL CONDITIONS: ------------------------------------------
param.y0 = [0.1*param.K 0.01*param.B0]; 
if depth < param.mesop % no meso in shallow areas. 
    param.y0(param.ix1(2):param.ix2(3))=0;        
end

% RUN FEISTY-SQUID MODEL: -----------------------------------------
results = poem(param);

% PLOT FIGURE: ------------------------------------------------------
% PANEL A: Low fishing feeding level
nexttile
plotdiet_squid(param, results, true)                            % Plot the diet of squid (true prints the legend)
ylabel('Fraction in stomach')               
xlabel('Size-class ')
title('A. Low fishing')
set(gca, 'FontSize', 11)

% PANEL C: Effect of large pelagic fishing on squid mortality
% PLOT MORTALITY OF SQUID AT LOW FISHING INTENSITY
nexttile(4, [1, 3])
plotmort_squid(param, results, '-')                            % Plot the mortality of squid ('-' is the line style)
title('C. Effect of large pelagic fishing on squid mortality')

%! CALCULATION AT HIGH FISHING INTENSITY : ----------------------------------
depth = 2000;                                                  % depth in m
Zoo_prod = 100;                                                % Zooplankton production (g ww m-2 yr -1)
param = baseparameters();                                      % Create parameter structure
param = baseparam_depth(param, depth);                         % Create depth related parameters
param.K = [Zoo_prod  Zoo_prod  0  0];                          % assign productivity for each resouce (based on van Denderen 2021)

% CALCULATION OF FISHING MORTALITY: ----------------------------
% USING HIGH FISHING INTENSITY OF 3 yr-1 FOR LARGE PELAGICS
param.Fi = [0.1, 0, 3, 0.1, 0.1];
F = [];
for fi = 1:param.nSpecies
    % FISHING MORTALITY EQUATION
    F = [F, param.Fi(fi) * (1+(param.wc(param.ix1(fi):param.ix2(fi))...
        ./(param.wu(param.ix2(fi))*0.05)).^(-3)).^(-1)];
end
param.F = F';

% INITIAL CONDITIONS: ------------------------------------------
param.y0 = [0.1*param.K 0.01*param.B0]; 
if depth < param.mesop % no meso in shallow areas. 
    param.y0(param.ix1(2):param.ix2(3))=0;        
end

% RUN FEISTY-SQUID MODEL: ---------------------------------------
results = poem(param);

% PLOT PANEL B: feeding level at high fishing intensity
nexttile(2)
plotdiet_squid(param, results, false)
xlabel('Size-class')
title('B. High fishing')
set(gca, 'FontSize', 11)

% PLOT PANEL C: Squid mortality at high fishing intensity
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


%% Sensitivity on zooplankton productivity with changing temperature
%
% Here, we run a zooplankton productivity sensitivity analysis of the FEISTY-squid at 
% 3 temperatures (10°C: base temperature of the model which correspond to the standard temperature of the Q10,
% 8°C, and 12°C) In order to assess how the ecosystem structure increase with temperature 
% for different productivity. 
% We also show that a wider variation of temperature (0 -- 30°C) do not affect the results 
% (see Supplementary_paper.mlx/.m)
% 
% ---------------------------------------------------------------------------------------%

% CLEAR EXISTING FIGURE:
if exist("fig3")
    clf(fig3)
end

fig3 = figure();                                    % Define figure

% Set up range of parameters: ---------------------------------------------
depth = [50 2000];                                  % Shallow and very deep ocean (m)                                         
Zoo_prod = linspace(5, 150, 40);                    % vector for Zoo production (g WW yr-1)
param = baseparameters();                           % set up basic param
titlelab = {'A. Shelf system', 'B. Open Ocean'};    % titles
temp = [8 12];                                      % Temperature experiments (°C)
LineStyl = {':', '--'};                             % Line style for temperature experiments
color_temp = [0.30, 0.75, 0.93;...                  % Color for temperature effect
              0.85, 0.33 ,0.10];                    % Light blue for 8°C and light red for 12°C
Visibility_temp = {'on', 'off'};                    % Define visibility for legend 
Visibility_sp = {'off', 'on'};

% SIMULATIONS AND PLOTS : ---------------------------------------------
t = tiledlayout(1, 2, TileSpacing='compact', Padding= 'compact');

for dp = 1:length(depth) %! loop depth 
    param = baseparam_depth(param, depth(dp));     % Depth specific parameters
    Bi = zeros(length(Zoo_prod), param.nSpecies);  % Storage variable biomass to compare with other temperature
    nexttile                                       % Change subplot location for each depth
    param = baseparam_temp(param, 4, 10);          % Temperature ref     

    for i = 1:length(Zoo_prod) %! Loop zooplankton productivity
        param.K =  [Zoo_prod(i), Zoo_prod(i), 0, 0];  % Defines zooplankton productivity for each resource in the model

        % SET INITIAL CONDITIONS OVER THE SIMULATIONS: -----------------------------
        if i == 1 % 1st run Initial condition
            param.y0 = [0.1*param.K 0.01*param.B0];           
        else % Start from previous final state. 
            param.y0 = results.y(end, :) + [0.1*param.K param.B0];
        end
        
        % NO MESOPELAGIC IN SHALLOW AREAS
        if(param.bottom <= param.mesop)
                param.y0(param.ix1(2):param.ix2(2)) = 0;
        end

        % RUN FEISTY-SQUID MODEL: ------------------------------------------------------
        results = poem(param);                    % Run model

        % AVERAGE LAST 40 TIME STEPS: 
        yend = mean(results.y((end - 40):end,:));

        % SUM AND AVERAGE OF BIOMASS PER FUNCTIONAL GROUP 
        for ii = 1:param.nSpecies 
            Bi(i, ii) =  sum(yend(:,param.ix1(ii):param.ix2(ii)));
        end 
    end% end loop zoo prod
    
    % TEMPERATURE EXPERIMENTS : ----------------------------
    for T = 1:length(temp)% loop temperature 
        param = baseparam_temp(param, 4, temp(T));       % Temperature effect on physiological parameters 
                                                         % (4 same temperature in the whole whater column) 
        Bi_T = zeros(length(Zoo_prod), param.nSpecies);  % Storage variable biomass to compare with other temperature  
                                            
        for i = 1:length(Zoo_prod) %! Loop zooplankton productivity
            param.K =  [Zoo_prod(i), Zoo_prod(i), 0, 0]; % Gives zoo prod to param
            
            % SET INITIAL CONDITIONS OVER THE SIMULATIONS: -----------------------------
            if i == 1 % 1st run Initial condition
                param.y0 = [0.1*param.K 0.01*param.B0];           
            else % Start from previous final state. 
                param.y0 = results.y(end, :) + [0.1*param.K param.B0];
            end
            
            % NO MESOPELAGIC IN SHALLOW AREAS
            if(param.bottom <= param.mesop)
                    param.y0(param.ix1(2):param.ix2(2)) = 0;
            end
            
            % RUN FEISTY-SQUID MODEL: ------------------------------------------------------
            results = poem(param);

            % AVERAGE LAST 40 TIME STEPS:
            yend = mean(results.y((end - 40):end,:));
    
            % SUM AND AVERAGE OF BIOMASS PER FUNCTIONAL GROUP
            for ii = 1:param.nSpecies 
                Bi_T(i, ii) =  sum(yend(:,param.ix1(ii):param.ix2(ii)));
            end 
        end 
        
        % PLOT BIOMASS AT TEMPERATURE T: ----------------------------------
        hold on
        for sp = 1:param.nSpecies %! Plot biomass for each group  
            ciplot(Bi(:, sp)', Bi_T(:, sp)', Zoo_prod, 'colour',  color_temp(T,:), ...
                'alpha', 0.5, 'Linestyle', 'none', 'VisLegend', 'off');
        end
        % COLOR THE DIFFERENCE BETWEEN TEMPERATURE EXP (8 OR 12°C) AND BASELINE (10°C): 
        ciplot(sum(Bi, 2), sum(Bi_T, 2), Zoo_prod, 'colour',  color_temp(T,:), ...
                'alpha', 0.5, 'Linestyle', 'none', 'VisLegend', Visibility_temp{dp});
    end % end loop temperature

    % PLOT BIOMASS AT EXP TEMPERATURES: ----------------------------------
    for sp = 1:param.nSpecies %! Plot biomass for each group                  
        plot(Zoo_prod, Bi(:, sp)', 'LineWidth', param.LWidth(sp), ... 
            'Color', param.Color(sp,:), 'HandleVisibility', Visibility_sp{dp})
    end
    plot(Zoo_prod, sum(Bi'), '--k', 'HandleVisibility', Visibility_sp{dp})
    hold off 
    title(titlelab{dp})
    
    % LEGEND 
    if dp ==1
        legend({'8°C', '12°C'} , 'Location', 'northeast', ...
            'Color','none', 'EdgeColor', 'none')
    else 
        legend([param.SpId{:}, {'Total'}] , 'Location', 'northwest', ...
            'Color','none', 'EdgeColor', 'none')
    end 
end
    
xlabel(t, 'Zooplankton productivity (g m^{-2} yr^{-1})')
ylabel(t, 'Biomass (g m^{-2})')

%! Save figure
if figsave
    save_graph(fig3, 'pdf', [save_dir 'Sens_Biomass_productivity_temp'], 16, 10)
end