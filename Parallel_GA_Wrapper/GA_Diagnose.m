% Diagnostic Script for Range Extension Simulation

function diagnose_simulation()
    % Clear workspace and existing parallel pool
    clear all; close all; clc;
    delete(gcp('nocreate'));
    
    % Detailed Simulation Diagnostic Function
    function [range, success] = test_single_simulation(weights)
        try
            % Initialize model parameters
            initialize_model_parameters(weights);
            
            % Logging input weights
            fprintf('Testing weights: [%.4f, %.4f, %.4f, %.4f]\n', ...
                weights(1), weights(2), weights(3), weights(4));
            
            % Simulation parameters
            tf = 19000;  % Total simulation time
            
            % Suppress warnings
            warning('off', 'all');
            
            % Run simulation with verbose error tracking
            try
                simout = sim('Range_ext_TCST_NoSDKF', 'TimeOut', 60);
                
                % Detailed output inspection
                disp('Simulation Output Structure:');
                disp(simout);
                
                % Check all possible range locations
                range_vars = {'range', 'Range', 'vehicle_range'};
                range_found = false;
                
                for i = 1:length(range_vars)
                    try
                        % Try to access range variable
                        if isprop(simout, range_vars{i})
                            current_range = double(eval(['simout.' range_vars{i} '.Data(end)']));
                            fprintf('Range found in %s: %.2f\n', range_vars{i}, current_range);
                            range = current_range;
                            range_found = true;
                            break;
                        end
                    catch var_err
                        fprintf('Error checking %s: %s\n', range_vars{i}, var_err.message);
                    end
                end
                
                % If no range found
                if ~range_found
                    % List all workspace variables
                    fprintf('Available workspace variables:\n');
                    whos
                    
                    range = NaN;
                    success = false;
                    return;
                end
                
                success = true;
            catch sim_err
                % Detailed Simulink simulation error handling
                fprintf('Simulink Simulation Error:\n');
                disp(sim_err);
                disp(sim_err.stack);
                
                range = NaN;
                success = false;
            end
        catch err
            % Catch-all error handling
            fprintf('Critical Error in Simulation:\n');
            disp(err);
            disp(err.stack);
            
            range = NaN;
            success = false;
        end
    end

    % Initialize Model Parameters Function
    function initialize_model_parameters(weights)
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
    end

    % Model Validation Checks
    function validate_model()
        % Load the model
        try
            load_system('Range_ext_TCST_NoSDKF');
            
            % Check model configuration
            disp('Model Configuration:');
            cfg = getActiveConfigSet('Range_ext_TCST_NoSDKF');
            disp(cfg);
            
            % List all blocks
            blocks = find_system('Range_ext_TCST_NoSDKF', 'Type', 'Block');
            fprintf('Total blocks in model: %d\n', length(blocks));
            
            % Check for potential issues
            disp('Potential Configuration Issues:');
            for i = 1:length(blocks)
                try
                    % Check specific block parameters
                    block_name = blocks{i};
                    
                    % Check for unresolved parameters
                    params = {'InitialCondition', 'Value', 'VariableName'};
                    for j = 1:length(params)
                        try
                            param_value = get_param(block_name, params{j});
                            if contains(param_value, {'x_0', 'weights', 't_simulator'})
                                fprintf('Potential unresolved parameter in %s: %s = %s\n', ...
                                    block_name, params{j}, param_value);
                            end
                        catch
                            % Silently skip if parameter doesn't exist
                        end
                    end
                catch
                    % Skip blocks that can't be processed
                end
            end
            
            % Close model
            close_system('Range_ext_TCST_NoSDKF');
        catch err
            disp('Error validating model:');
            disp(err);
        end
    end

    % Main Diagnostic Workflow
    try
        % Validate model first
        validate_model();
        
        % Test simulation with different weight configurations
        test_weights_sets = [
            0.25, 0.25, 0.25, 0.0001;   % Baseline weights
            0.5, 0.3, 0.2, 0.0001;      % Alternative weights
            rand(1,3), 0.0001;           % Random weights
        ];
        
        % Run diagnostic simulations
        for i = 1:size(test_weights_sets, 1)
            fprintf('\n--- Simulation Test %d ---\n', i);
            current_weights = test_weights_sets(i, :);
            
            [range, success] = test_single_simulation(current_weights);
            
            fprintf('Simulation %d Results:\n', i);
            fprintf('Weights: [%.4f, %.4f, %.4f, %.4f]\n', ...
                current_weights(1), current_weights(2), current_weights(3), current_weights(4));
            fprintf('Success: %d\n', success);
            fprintf('Range: %.2f\n', range);
        end
    catch ME
        disp('Diagnostic Script Error:');
        disp(ME);
    end
end

% Execute diagnostic script
diagnose_simulation();