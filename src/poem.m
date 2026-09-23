function result = poem(param, result)
    % FUNCTION TO RUN THE ODE
    % INPUTS:
    %  param: structure with model parameters
    %  result: structure with model outputs
    % OUTPUTS:
    %   result: structure with model outputs
    % Originally written by P. Daniël Van Denderen, 
    % modified by Remy Denechere <remy.denechere@proton.me>


% INITIAL CONDITIONS:
y0 = param.y0;
 
% ODE SOLVER
[t, y] = ode23(@poem_deriv, 0:1:param.tEnd, y0, odeset('NonNegative', 1:length(y0)), param);


% ENCAPSULATE RESULTS INTO STRUCTURE:
result.y = y;                                               % Biomass of all size classes of fish + resources 
result.R = y(:,param.ixR);                                  % biomass of the resource   
result.B = y(:,param.ixFish);                               % biomass of the fish
result.t = t;                                               % Time vector (years) output for ODE solver 
result.Yield = result.B .* (ones(length(t),1)*param.F');    % Fishing yield

B = mean(result.B(end-40:end,:)); % result.B(end,:); %      % Mean biomass of the fish over the last 40 time steps
y = mean(y(end-40:end,:)); % y(end,:); %                    % Mean biomass of all size classes of fish + resources over the last 40 time steps

% SOME MORE SPECIFIC OUTPUTS: (feeding level, predation mortality, available energy)
[result.f, result.mortpred, result.Eavail] = calcEncounter(y', param);
result.mort = result.mortpred(param.ixFish)' + param.mort0 + param.F;
[result.v , result.nu] = calcNu(result.Eavail, result.mort, param);



