% number of weights
nvars = 4;

% Lower and upper bounds for weights
lb = [0, 0, 0, 0];  
ub = [1, 1, 1, 0.0001]; 


% GA options
options = optimoptions('ga', ...
    'PopulationSize', 5, ...          
    'MaxGenerations', 2, ...         
    'CrossoverFraction', 0.8, ...      
    'MutationFcn', {@mutationuniform, 0.1}, ... 
    'Display', 'iter', ...             
    'UseParallel', false);              

% Run the GA
[optimal_weights, fval] = ga(@objective_function, nvars, [], [], [], [], lb, ub, [], options);

% Display results
fprintf('Optimal Weights: w1=%.4f, w2=%.4f, w3=%.4f, wPL=%.6f\n', ...
    optimal_weights(1), optimal_weights(2), optimal_weights(3), optimal_weights(4));
fprintf('Maximum Range Achieved: %.2f\n', -fval);
