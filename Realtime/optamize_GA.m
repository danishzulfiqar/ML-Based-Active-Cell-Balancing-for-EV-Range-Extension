clc
clear
close all

% Define the objective function
objective = @(x) -test_model(x(1), x(2), x(3), x(4), 'FHDS_extended');

% Lower and upper bounds for weights
lb = [0, 0, 0, 0];
ub = [1, 1, 1, 0.0001];

% Number of variables
nvars = 4;

% Linear constraint (sum of first three weights should be 1)
A = [1 1 1 0];
b = 1;

% Custom constraint function to ensure w1 + w2 + w3 = 1
constraint = @(x) deal([], 1 - (x(1) + x(2) + x(3)));

% Custom output function to display iteration results
outputFcn = @gaOutputFcn;

% GA options
options = optimoptions('ga', ...
    'Display', 'iter', ...
    'PopulationSize', 5, ...
    'MaxGenerations', 100, ...
    'FunctionTolerance', 1e-6, ...
    'PlotFcn', @gaplotbestf, ...
    'OutputFcn', outputFcn, ...
    'CrossoverFraction', 0.8, ...
    'MutationFcn', @mutationadaptfeasible);

% Run the optimization
[x_opt, fval] = ga(objective, nvars, A, b, [], [], lb, ub, constraint, options);

% Display final results
disp('Best weights found:');
disp(['w1: ', num2str(x_opt(1))]);
disp(['w2: ', num2str(x_opt(2))]);
disp(['w3: ', num2str(x_opt(3))]);
disp(['wPL: ', num2str(x_opt(4))]);
disp(['Maximum range: ', num2str(-fval)]);

% Define the custom output function within the script
function [state, options, optchanged] = gaOutputFcn(options, state, flag)
    optchanged = false;
    if strcmp(flag, 'iter')
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