% Number of weights
nvars = 4;

% Lower and upper bounds for weights
lb = [0, 0, 0, 0];
ub = [1, 1, 1, 0.0001];

% Initial guess for weights
initial_guess = [0.5, 0.5, 0.5, 0.00005];

% Simulated Annealing options
options = optimoptions('simulannealbnd', ...
    'MaxIterations', 1, ...         % Maximum number of iterations
    'InitialTemperature', 1, ...      % Initial temperature for annealing
    'TemperatureFcn', @temperatureexp, ... % Exponential temperature function
    'AnnealingFcn', @annealingfast, ...    % Annealing schedule
    'Display', 'iter', ...            % Display iteration details
    'MaxFunctionEvaluations', 2);   % Maximum number of function evaluations

% Run Simulated Annealing
[optimal_weights, fval] = simulannealbnd(@objective_function, initial_guess, lb, ub, options);

% Display results
fprintf('Optimal Weights: w1=%.4f, w2=%.4f, w3=%.4f, wPL=%.6f\n', ...
    optimal_weights(1), optimal_weights(2), optimal_weights(3), optimal_weights(4));
fprintf('Maximum Range Achieved: %.2f\n', -fval);