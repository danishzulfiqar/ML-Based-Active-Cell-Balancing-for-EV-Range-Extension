% Main script for genetic algorithm optimization
clear
close all
clc
tic

% Initial parameters
H=0.9; M=0.8; L=0.7;
x_0=[H;M;L]; %intial state vector
Stop_SOC=0.1; % Stop simulation when any cell's SOC reaches this value
load('CurrentVelocityData/FHDS_extended.mat');
i_simulator=i;
t_simulator=t;
t_vel=t;
vel_simulator=vel;
i_simulator=-2.5*(i_simulator/max(i_simulator)); %-3.2 is the scaling factor for FUDS_Extended
delta=5; %step size for simulation

% Define global variables to be used in objective function
global DC S_factor
DC = 'FHDS';
S_factor = 2.5;

% Initialize variables for Simulink model - important!
% Use the default weights as initial values
weights = [0.15; 0.84; 0.00; 0.000091];
assignin('base', 'weights', weights);  % Make it available to Simulink

% Number of weights
nvars = 4;

% Lower and upper bounds for weights
lb = [0, 0, 0, 0];  
ub = [1, 1, 1, 0.0001]; 

% GA options
options = optimoptions('ga', ...
    'PopulationSize', 10, ...          
    'MaxGenerations', 10, ...         
    'CrossoverFraction', 0.8, ...
    'StallGenLimit', 10, ...              % Stop if no improvement for 10 generations
    'MutationFcn', {@mutationuniform, 0.2}, ... 
    'Display', 'iter', ...             
    'UseParallel', false);              

% Run the GA
[optimal_weights, fval] = ga(@objective_function, nvars, [], [], [], [], lb, ub, [], options);

% Display results
fprintf('Optimal Weights: w1=%.4f, w2=%.4f, w3=%.4f, wPL=%.6f\n', ...
    optimal_weights(1), optimal_weights(2), optimal_weights(3), optimal_weights(4));
fprintf('Maximum Range Achieved: %.2f\n', -fval);
toc

% Objective function definition
function fitness = objective_function(weights_input)
    global DC S_factor
    
    % Copy the input weights to avoid modifying the input parameter
    w_values = weights_input;
    
    w1 = w_values(1);
    w2 = w_values(2);
    w3 = w_values(3);
    w_PL = w_values(4);
    
    % Normalize weights for w1, w2, w3 to sum to 1
    weights_sum = sum(w_values(1:3));
    if weights_sum > 0
        w1 = w1 / weights_sum;
        w2 = w2 / weights_sum;
        w3 = w3 / weights_sum;
    end
    
    % Round w1, w2, and w3 to 2 decimal places
    w1 = round(w1, 2);
    w2 = round(w2, 2);
    w3 = round(w3, 2);
    
    % Check bounds
    lb = [0, 0, 0, 0];
    ub = [1, 1, 1, 0.0001];
    
    if any(w_values < lb) || any(w_values > ub)
        fitness = 1e6;
        return;
    end
    
    % Run the Simulink model
    try
        tf=19000;
        H=0.9; M=0.8; L=0.7;
        x_0=[H;M;L]; %intial state vector
        Stop_SOC=0.1; % Stop simulation when any cell's SOC reaches this value
        load('CurrentVelocityData/FHDS_extended.mat');
        i_simulator=i;
        t_simulator=t;
        t_vel=t;
        vel_simulator=vel;
        i_simulator=-2.5*(i_simulator/max(i_simulator)); %-3.2 is the scaling factor for FUDS_Extended
        delta=5; %step size for simulation
        
        % Prepare weights for simulation
        normalized_weights = [w1; w2; w3; w_PL];
        
        % IMPORTANT: Make sure to assign the weights to the base workspace
        assignin('base', 'weights', normalized_weights);
        
        % Run simulation
        simout = sim('Range_ext_TCST_NoSDKF', tf);

        print(simout);
        
        % Save results
        if ~exist('GeneratedData', 'dir')
            mkdir('GeneratedData');
        end
        
        save_filename = sprintf('GeneratedData/Simulation_DC_%s_SF_%.2f_SOC_H%.2f_M%.2f_L%.2f_w1_%.2f_w2_%.2f_w3_%.2f_wPL_%f.mat', DC, S_factor, H, M, L, w1, w2, w3, w_PL);
        
        % Get simulation results from base workspace
        if evalin('base', 'exist(''range'', ''var'')')
            range = evalin('base', 'range');
            t_sim = evalin('base', 't_sim');
            
            % Check for other variables
            variables_to_save = {'D1', 'soc_M', 'J', 'I_cd', 'v_t', 'PLoss', 'P_IO', 'I_b', 'I_cells'};
            save_data = struct('range', range, 't_sim', t_sim, 'w1', w1, 'w2', w2, 'w3', w3, 'DC', DC, 'S_factor', S_factor, 'H', H, 'M', M, 'L', L, 'w_PL', w_PL);
            
            for i = 1:length(variables_to_save)
                if evalin('base', ['exist(''', variables_to_save{i}, ''', ''var'')'])
                    save_data.(variables_to_save{i}) = evalin('base', variables_to_save{i});
                end
            end
            
            save(save_filename, '-struct', 'save_data');
            
            % Extract range from simulation output
            if ~isempty(range)
                fprintf('Final range for w1=%.2f, w2=%.2f, w3=%.2f, wPL=%.6f : %.2f\n', w1, w2, w3, w_PL, range(end));
                fitness = -range(end);  % negative because we want to maximize range
            else
                fprintf('Range is empty for w1=%.2f, w2=%.2f, w3=%.2f, wPL=%.6f\n', w1, w2, w3, w_PL);
                fitness = 1e3; % penalty
            end
        else
            fprintf('Range variable not found for w1=%.2f, w2=%.2f, w3=%.2f, wPL=%.6f\n', w1, w2, w3, w_PL);
            fitness = 1e3; % penalty
        end
    catch ME
        % Display detailed error for debugging
        fprintf('Error in simulation: %s\n', ME.message);
        disp(getReport(ME, 'extended'));
        fitness = 1e3; % penalty
    end
end