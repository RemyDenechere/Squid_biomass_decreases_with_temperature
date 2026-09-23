%% Supplementary: 
% This script generates the figures of the supplementary materials for the paper: 
% "Squid biomass increase is not explain by rising temperature but rather loss of top predators."
% 
% Remy Denechere <remy.denechere@proton.me>

%% Initialization 
clear all 
clf 

% CREATE FIGURE DIRECTORY IF NOT EXISTING
save_dir = '../Fig/';       % path to save figures
if ~exist(save_dir)         % check if the directory exists
    mkdir(save_dir)         % create the directory if it does not exist
end 

figsave = true;             % Set to true to save figures   

%% Effect of large pelagic fishing on squid feeding level and mortality in a shallow system
% 
% ---------------------------------------------------------------------------------------%% 
% CLEAR EXISTING FIGURE:
if exist("fig1")
    clear fig1
end
fig1 = figure();                               % Define figure variable

% CREATE TILED LAYOUT FOR PANEL PLOT:
tiledlayout(2, 3, "TileSpacing", "loose", "Padding", "compact");

% PARAMETER SET : ---------------------------------------------------------
depth = 50;                                     % Depth in m                                           
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
% RESET ALL PARAMETERS: 
depth = 50;                                                    % depth in m
Zoo_prod = 100;                                                % Zooplankton production (g ww m-2 yr -1)
param = baseparameters();                                      % Create parameter structure
param = baseparam_depth(param, depth);                         % Create depth related parameters
param.K = [Zoo_prod  Zoo_prod  0  0];                          % assign productivity for each resouce (based on van Denderen 2021)

% CALCULATION OF FISHING MORTALITY: ----------------------------
% USING HIGH FISHING INTENSITY OF 3 yr-1 FOR LARGE PELAGICS
param.Fi = [0.1, 0, 0.1, 3, 0.1];
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
    save_graph(fig1, 'pdf', [save_dir 'F_mort_squid_Shallow'], 16, 10)
end

%% Supplement B: Effect of varying 𝑄10 assumptions 
% Between max consumption, clearance rate and metabolism for squid.
% we tested three scenarios:
% 1. Q10 for consumption > Q10 for metabolism (1.88 vs 1.5)
% 2. Q10 for consumption = Q10 for metabolism (1.88 vs 1.88)
% 3. Q10 for consumption < Q10 for metabolism (1.5 vs 1.88) 

% CLEAR EXISTING FIGURE:
if exist("fig2")
    clear fig2
end
fig2 = figure();

% PARAMETER SET : ---------------------------------------------------------
depth = [50 2000];                              % Depth in m
Zoo_prod = 150;                                 % Zooplankton production in mg m^-2 yr^-1              
param = baseparameters();                       % Set base parameters structure
T = linspace(8, 12, 10);                        % Set temperature range for sensitivity analysis
TEMP = ones(10, param.nSpecies);                % Initialize temperature array
param.K = [Zoo_prod Zoo_prod 0 0];              % Set productivity for each resource
param.y0 = [0.1*param.K 0.01*param.B0];         % Set initial conditions for each species

Q10  =  [1.88  1.88   1.5];                     % Q10 for consumption.
Q10m =  [1.5   1.88   1.5];                     % Q10 for Standard metabolism. 
linestyle = {':', '-', '--'};                   % Line styles for plotting each case

% PLOT FIGURE: ------------------------------------------------------
tlayout = tiledlayout(1, 2, Padding="compact", TileSpacing="compact");

for dp = 1:2% Loop depth
    nexttile
    % SET UP DEPTH PARAMETERS
    param = baseparam_depth(param, depth(dp));

    % SET INITIAL CONDITIONS (no mesozooplankton in shallow areas)
    if depth(dp) < 250
        param.y0(param.ix1(2):param.ix2(2)) = 0;
    end
    hold on 
    for i = 1:3 % loop Q10
        % SET Q10 PARAMETERS FOR EACH SCENARIO
        param.Q10(param.ix1(5):param.ix2(5)) = Q10(i);
        param.Q10m(param.ix1(5):param.ix2(5)) = Q10m(i);
    
        for t = 1:10 % Loop Temperature: --------------------------------
            param = baseparam_temp(param, 4, T(t));                        % Assumption that reference temperature for the system = 10
            results = poem(param);                                         % Run the model with the current parameters
            y = mean(results.y(end-40:end,:));                             % Compute the mean biomass over the last 40 time steps

            % TOTAL BIOMASS FOR EACH SPECIES
            for ii = 1:param.nSpecies                                   
                TEMP(t,ii) = sum(y(param.ix1(ii):param.ix2(ii)));
            end
        end
        % SET UP LEGEND VISIBILITY BASED ON DEPTH AND SCENARIO
        if dp == 1 
            visibility = ["off", "off", "off", "on", "off"];
        else 
            if i == 2
                visibility = ["on", "on", "on", "on", "on"];
            else
                visibility = ["off", "off", "off", "off", "off"];
            end 
        end 

        % PLOT BIOMASS VS TEMPERATURE FOR EACH SPECIES: ----------------------------
        for ii = 1:param.nSpecies
            idx = TEMP(:,ii) > 0 ; % only positive biomass for log scale 
            plot(T(idx), TEMP(idx,ii), 'LineWidth', param.LWidth(ii),...
                'color', param.Color(ii, :), 'LineStyle', linestyle{i}, ...
                'HandleVisibility', visibility(ii));
        end 
        title(['Depth = ', num2str(depth(dp)), ' m'])
        set(gca, 'YScale', 'log', 'Ylim', [0.5 50]) % 

        if dp == 1
            Leg = legend('Q_{10} > Q_{10m} ', 'Q_{10} = Q_{10m}', 'Q_{10} < Q_{10m}', 'Location', 'best');
        else
            Leg = legend(param.SpId{[1, 3:end]}, 'Location', 'best');
        end  
    end
    hold off
    Leg.Box = 'off'; Leg.EdgeColor = 'none'; Leg.Color = 'none';
end

xlabel(tlayout, 'Average T (°C)')
ylabel(tlayout, 'Biomass (g ww m^{-2})')

if figsave
    save_graph(fig2, 'pdf', [save_dir,'Sens_temp_Q10'], 16, 8)
end


%% Supplement C: Effect of varying 𝑄10 assumptions between fish and squid
% We tested three scenarios:
% 1. Q10 for fish > Q10 for squid (2.5 vs 1.88)
% 2. Q10 for fish = Q10 for squid (1.88 vs 1.88)
% 3. Q10 for fish < Q10 for squid (1.88 vs 1.5)
% value for squid are supposed to be unrealistically high and low respectively,
% but they are used to illustrate the effect of Q10 assumptions on the model results.

% CLEAR EXISTING FIGURE:
if exist("fig3")
    clear fig3
end

fig3 = figure();

% PARAMETER SET : ---------------------------------------------------------
depth = [50 2000];                                      % Depth in m
Zoo_prod = 150;                                         % Zooplankton production in mg m^-2 yr^-1
param = baseparameters();                               % Set base parameters structure
T = linspace(8, 12, 10);                                % Set temperature range for sensitivity analysis
TEMP = ones(10, param.nSpecies);                        % Initialize temperature array
param.K = [Zoo_prod Zoo_prod 0 0];                      % Set productivity for each resource
param.y0 = [0.1*param.K 0.01*param.B0];                 % Set initial conditions for each species

Q10  =  [1   1.88   2.5];                               % Q10 for consumption.
Q10m =  [1   1.88   2.5];                               % Q10 for Standard metabolism. 
linestyle = {':', '-', '--'};                           % Line styles for plotting each case

% PLOT FIGURE: ------------------------------------------------------
tlayout = tiledlayout(1, 2, Padding="compact", TileSpacing="compact");

for dp = 1:2 % Loop depth
    nexttile
    param = baseparam_depth(param, depth(dp));          % Set up depth parameters
    % REMOVE MESOZOO IN SHALLOW AREAS
    if depth(dp) < 250
        param.y0(param.ix1(2):param.ix2(2)) = 0;
    end
    hold on 
    for i = 1:3
        % SET Q10 PARAMETERS FOR EACH SCENARIO
        param.Q10(param.ix1(5):param.ix2(5)) = Q10(i);
        param.Q10m(param.ix1(5):param.ix2(5)) = Q10m(i);   
       
        for t = 1:10  % Loop Temperature: --------------------------------
            param = baseparam_temp(param, 4, T(t));                         % Assumption that reference temperature for the system = 10
            results = poem(param);                                          % Run the model with the current parameters
            y = mean(results.y(end-40:end,:));                              % Compute the mean biomass over the last 40 time steps         

            % TOTAL BIOMASS FOR EACH SPECIES
            for ii = 1:param.nSpecies
                TEMP(t,ii) = sum(y(param.ix1(ii):param.ix2(ii)));
            end
        end

        % SET VISIBILITY OF LINES BASED ON DEPTH AND SCENARIO   
        if dp == 1 
            visibility = ["off", "off", "off", "on", "off"];
        else 
            if i == 2
                visibility = ["on", "on", "on", "on", "on"];
            else
                visibility = ["off", "off", "off", "off", "off"];
            end 
        end 

        % PLOT BIOMASS VS TEMPERATURE FOR EACH SPECIES: ----------------------------
        for ii = 1:param.nSpecies
            idx = TEMP(:,ii) > 0 ; 
            plot(T(idx), TEMP(idx,ii), 'LineWidth', param.LWidth(ii),...
                'color', param.Color(ii, :), 'LineStyle', linestyle{i}, ...
                'HandleVisibility', visibility(ii));
        end 
        title(['Depth = ', num2str(depth(dp)), ' m'])
        set(gca, 'YScale', 'log', 'Ylim', [0.1 100]) % 

        if dp == 1
            Leg = legend('Q_{10, Fish} > Q_{10, Squid} ', ...
                         'Q_{10, Fish} = Q_{10, Squid} ' , ...
                         'Q_{10, Fish} < Q_{10, Squid} ' , 'Location', 'best');
        else
            Leg = legend(param.SpId{[1, 3:end]}, 'Location', 'best');
        end  
    end
    hold off
    Leg.Box = 'off'; Leg.EdgeColor = 'none'; Leg.Color = 'none';
end

xlabel(tlayout, 'Average T (°C)')
ylabel(tlayout, 'Biomass (g ww m^{-2})')

save_graph(fig3, 'pdf', [save_dir,'Sens_temp_Q10_fish_and_Squid'], 16, 8)

%% Sensitivity on zooplankton productivity with changing temperature
%
% Here, we run a zooplankton productivity sensitivity analysis of the FEISTY-squid at 
% 3 temperatures (10°C: base temperature of the model which correspond to the standard temperature of the Q10,
% 1°C, and 35°C) 
% This is similar to what is done in the main figures, but with a wider
% range of temperature, it allows us to confirm that colder and warmer
% temperature have a consistent effect on ecosystem structure regardless of
% the value of T. 
% 
% ---------------------------------------------------------------------------------------%

% CLEAR EXISTING FIGURE:
if exist("fig4")
    clf(fig4)
end
fig4 = figure();                                    % Define figure

% Set up range of parameters: ---------------------------------------------
depth = [50 2000];                                  % Shallow and very deep ocean (m)                                         
Zoo_prod = linspace(5, 150, 40);                    % vector for Zoo production (g WW yr-1)
param = baseparameters();                           % set up basic param
titlelab = {'A. Shelf system', 'B. Open Ocean'};    % titles
temp = [1 35];                                      % Temperature experiments (°C)
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
        legend({'1°C', '35°C'} , 'Location', 'northeast', ...
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
    save_graph(fig4, 'pdf', [save_dir 'Sens_Biomass_productivity_temp_1_35'], 16, 10)
end