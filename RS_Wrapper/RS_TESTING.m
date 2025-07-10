% Number of weights
nvars = 4;

% Lower and upper bounds for weights
lb = [0, 0, 0, 0];
ub = [1, 1, 1, 0.0001];

% Number of random samples to evaluate
num_samples = 2;

% Initialize variables to store the best solution
best_weights = [];
best_fitness = Inf;

% Perform random search
for i = 1:num_samples
    % Generate random weights within the bounds
    random_weights = lb + rand(1, nvars) .* (ub - lb);

    % Evaluate the objective function
    fitness = objective_function(random_weights);

    % Update the best solution if current fitness is better
    if fitness < best_fitness
        best_fitness = fitness;
        best_weights = random_weights;
    end
end

% Display results
fprintf('Optimal Weights: w1=%.4f, w2=%.4f, w3=%.4f, wPL=%.6f\n', ...
    best_weights(1), best_weights(2), best_weights(3), best_weights(4));
fprintf('Maximum Range Achieved: %.2f\n', -best_fitness);