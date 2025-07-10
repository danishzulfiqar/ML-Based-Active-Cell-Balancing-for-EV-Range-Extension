clc
clear
close all

% Define drive cycles
drive_cycles = {'FHDS_extended', 'FUDS_extended', 'FUDSfast_extended', 'NEDC_extended', 'US06City_extended', 'US06HW_extended', 'US06_extended'};

% Lower and upper bounds for weights
lb = [0, 0, 0, 0];
ub = [1, 1, 1, 0.0001];

% Number of variables
nvars = 4;

% Define initial population (seed points)
initial_pop = [
    0.9500, 0.9700, 0.8100, 0.0000002000;  % FHDS_extended
    0.9500, 0.7500, 0.6100, 0.0000717000;  % FUDS_extended
    0.7800, 0.8100, 0.0000, 0.0000996000;  % FUDSfast_extended
    0.3400, 0.7000, 0.2400, 0.0000765000;  % NEDC_extended
    0.4800, 0.6000, 0.9100, 0.0000713000;  % US06City_extended
    0.7000, 1.0000, 0.2600, 0.0000920000;  % US06HW_extended
    1.0000, 1.0000, 0.0000, 0.0001000000;  % US06_extended
];

% Store results
results = cell(length(drive_cycles), 2);

for i = 1:length(drive_cycles)
    DC = drive_cycles{i};
    disp(['Optimizing for drive cycle: ' DC]);
    
    % Define the objective function for the current drive cycle
    objective = @(x) -test_model(x(1), x(2), x(3), x(4), DC);
    
    % Custom output function to display iteration results
    outputFcn = @(options, state, flag) gaOutputFcn(options, state, flag, DC);
    
    % GA options
    options = optimoptions('ga', ...
        'Display', 'iter', ...
        'PopulationSize', 20, ...
        'MaxGenerations', 100, ...
        'FunctionTolerance', 1e-6, ...
        'OutputFcn', outputFcn, ...
        'CrossoverFraction', 0.2, ...
        'MutationFcn', @mutationadaptfeasible, ...
        'InitialPopulation', initial_pop);
    
    % Run the optimization
    [x_opt, fval] = ga(objective, nvars, [], [], [], [], lb, ub, [], options);
    
    % Store results
    results{i, 1} = DC;
    results{i, 2} = x_opt;
    
    % Display results for this drive cycle
    disp(['Best weights found for ' DC ':']);
    disp(['w1: ', num2str(x_opt(1))]);
    disp(['w2: ', num2str(x_opt(2))]);
    disp(['w3: ', num2str(x_opt(3))]);
    disp(['wPL: ', num2str(x_opt(4))]);
    disp(['Maximum range: ', num2str(-fval)]);
    disp('------------------------');
end

% Display summary of results
disp('Summary of optimal weights for all drive cycles:');
for i = 1:length(drive_cycles)
    DC = results{i, 1};
    weights = results{i, 2};
    disp([DC ': w1=' num2str(weights(1)) ', w2=' num2str(weights(2)) ...
          ', w3=' num2str(weights(3)) ', wPL=' num2str(weights(4))]);
end

% Define the custom output function within the script
function [state, options, optchanged] = gaOutputFcn(options, state, flag, DC)
    optchanged = false;
    if strcmp(flag, 'iter')
        disp(['Drive Cycle: ' DC]);
        disp(['Generation: ' num2str(state.Generation)]);
        disp(['Best Range: ' num2str(-state.Best(end))]);
        [~, idx] = min(state.Score);
        best_individual = state.Population(idx, :);
        disp(['Best Weights: w1=' num2str(best_individual(1)) ...
              ', w2=' num2str(best_individual(2)) ...
              ', w3=' num2str(best_individual(3)) ...
              ', wPL=' num2str(best_individual(4))]);
        disp('------------------------');
    end
end