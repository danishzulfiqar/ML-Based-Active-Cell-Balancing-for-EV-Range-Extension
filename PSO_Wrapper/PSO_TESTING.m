% Number of weights
nvars = 4;

% Lower and upper bounds for weights
lb = [0, 0, 0, 0];
ub = [1, 1, 1, 0.0001];

% PSO options
options = optimoptions('particleswarm', ...
    'SwarmSize', 2, ...             % Number of particles
    'MaxIterations', 1, ...         % Maximum number of iterations
    'Display', 'iter', ...           % Display iteration information
    'UseParallel', false, ...        % Disable parallel computation
    'SelfAdjustmentWeight', 1.5, ... % Cognitive weight
    'SocialAdjustmentWeight', 1.5, ... % Social weight
    'InertiaRange', [0.4, 0.9]);     % Inertia weight range

% Run the PSO
[optimal_weights, fval] = particleswarm(@objective_function, nvars, lb, ub, options);

% Display results
fprintf('Optimal Weights: w1=%.4f, w2=%.4f, w3=%.4f, wPL=%.6f\n', ...
    optimal_weights(1), optimal_weights(2), optimal_weights(3), optimal_weights(4));
fprintf('Maximum Range Achieved: %.2f\n', -fval);
