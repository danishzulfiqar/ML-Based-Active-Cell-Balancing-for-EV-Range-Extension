% Comprehensive Range Extension Optimization Script

% Clear previous workspace and close existing parallel pool
clear all; close all; clc;
delete(gcp('nocreate'));

% Main Optimization Function
function [optimal_weights, max_range] = range_extension_optimization()
    % Create parallel pool if not exists
    if isempty(gcp('nocreate'))
        parpool('local');
    end
    
    % Set random seed for reproducibility
    rng(42, 'twister');
    
    % Genetic Algorithm Options
    options = optimoptions('ga', ...
        'PopulationSize', 50, ...           % Increased population
        'MaxGenerations', 20, ...           % More generations
        'CrossoverFraction', 0.8, ...       % High crossover rate
        'MutationFcn', {@mutationuniform}, ... % Uniform mutation
        'UseParallel', true, ...            % Enable parallel processing
        'Display', 'iter', ...              % Display iteration info
        'PlotFcn', {@gaplotbestf}, ...      % Convergence plot
        'FunctionTolerance', 1e-6, ...      % Convergence tolerance
        'MaxStallGenerations', 5);          % Stop if no improvement
    
    % Define problem constraints
    nvars = 4;              % Number of weights
    lb = [0, 0, 0, 0];      % Lower bounds
    ub = [1, 1, 1, 0.0001]; % Upper bounds
    
    % Run Genetic Algorithm
    [optimal_weights, max_range, exitflag, output] = ga(...
        @objective_function, ...    % Objective function
        nvars, ...                  % Number of variables
        [], [], [], [], ...         % Linear constraints (none)
        lb, ub, ...                 % Bounds
        [], ...                     % Nonlinear constraints (none)
        options);                   % GA options
    
    % Negate max_range since GA minimizes
    max_range = -max_range;
    
    % Display results
    fprintf('\n--- Optimization Results ---\n');
    fprintf('Optimal Weights: [%.4f, %.4f, %.4f, %.4f]\n', ...
        optimal_weights(1), optimal_weights(2), optimal_weights(3), optimal_weights(4));
    fprintf('Maximum Range: %.2f km\n', max_range);
end

% Objective Function for Genetic Algorithm
function fitness = objective_function(weights)
    % Error handling wrapper
    try
        % Initialize model parameters
        initialize_model_parameters(weights);
        
        % Validate weights
        if any(weights < 0) || any(weights > 1)
            fitness = 1e6;  % Penalty for out-of-bounds weights
            return;
        end
        
        % Normalize first three weights
        normalized_weights = weights(1:3) ./ sum(weights(1:3));
        weights_normalized = [normalized_weights, weights(4)];
        
        % Logging
        fprintf('Processing weights: [%.4f, %.4f, %.4f, %.4f]\n', ...
            weights_normalized(1), weights_normalized(2), ...
            weights_normalized(3), weights_normalized(4));
        
        % Simulink Simulation
        try
            % Simulation parameters
            tf = 19000;  % Total simulation time
            
            % Suppress warnings and output
            warning('off', 'all');
            
            % Run simulation
            simout = sim('Range_ext_TCST_NoSDKF', 'TimeOut', 60);
            
            % Extract range
            if ~isempty(simout.range)
                % Negate for minimization problem (GA minimizes)
                fitness = -double(simout.range.Data(end));
                
                % Logging successful run
                fprintf('Simulation successful. Range: %.2f\n', -fitness);
            else
                % Handle missing range data
                fprintf('No range data found\n');
                fitness = 1e3;
            end
        catch sim_err
            % Simulink simulation error handling
            fprintf('Simulink Simulation Error: %s\n', sim_err.message);
            fitness = 1e3;
        end
    catch err
        % Catch-all error handling
        fprintf('Critical Error in Objective Function:\n');
        disp(err.message);
        fitness = 1e6;
    end
end

% Initialize Model Parameters
function initialize_model_parameters(weights)
    % Persistent variables to maintain state across calls
    persistent last_weights
    
    % Check if weights have changed
    if isempty(last_weights) || ~isequal(weights, last_weights)
        % Normalize first three weights
        normalized_weights = weights(1:3) ./ sum(weights(1:3));
        weights_normalized = [normalized_weights, weights(4)];
        
        % Initial conditions
        x_0 = [0.8; 0.7; 0.6];  % Initial state of charge for different battery levels
        
        % Simulation time vectors
        t_simulator = 0:1:19000;
        t_vel = 0:1:19000;
        
        % Additional parameters
        Stop_SOC = 0.1;  % Stopping State of Charge
        
        % Update base workspace
        assignin('base', 'weights', weights_normalized);
        assignin('base', 'x_0', x_0);
        assignin('base', 't_simulator', t_simulator);
        assignin('base', 't_vel', t_vel);
        assignin('base', 'Stop_SOC', Stop_SOC);
        
        % Update last weights
        last_weights = weights;
    end
end

% Main Execution
try
    % Ensure parallel pool is available
    if isempty(gcp('nocreate'))
        parpool('local');
    end
    
    % Set random seed
    rng(42, 'twister');
    
    % Run optimization
    [optimal_weights, max_range] = range_extension_optimization();
    
    % Clean up
    delete(gcp('nocreate'));
catch ME
    % Display any errors
    disp('Error in optimization:');
    disp(ME.message);
    
    % Ensure parallel pool is closed
    delete(gcp('nocreate'));
end