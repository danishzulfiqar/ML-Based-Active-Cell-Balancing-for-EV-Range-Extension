tic
clear
close all
clc

Stop_SOC = 0.1;  % Stop simulation when any cell's SOC reaches this
delta = 5;       % Step size for simulation

% Define scaling factors mapping
scaling_factors_map = containers.Map(...
    {'FHDS_extended', 'FUDS_extended', 'FUDSfast_extended', 'NEDC_extended', 'US06City_extended', 'US06HW_extended', 'US06_extended'}, ...
    [-2.5, -3.2, -5, -2.7, -5.7, -8, -8]);

% Input format: w1,w2,w3,wPL,DriveCycleName
% data = {
%     % Test weights (Individual Cost)
%     1,0,0,0.0000002000,'FHDS_extended';
%     0,1,0,0.0000002000,'FHDS_extended';
%     0,0,1,0.0000002000,'FHDS_extended';
%     1,0,0,0.0000996000,'FUDSfast_extended';
%     0,1,0,0.0000996000,'FUDSfast_extended';
%     0,0,1,0.0000996000,'FUDSfast_extended';
%     1,0,0,0.0000765000,'NEDC_extended';
%     0,1,0,0.0000765000,'NEDC_extended';
%     0,0,1,0.0000765000,'NEDC_extended';
%     1,0,0,0.0000717000,'FUDS_extended';
%     0,1,0,0.0000717000,'FUDS_extended';
%     0,0,1,0.0000717000,'FUDS_extended';
%     1,0,0,0.0000713000,'US06City_extended';
%     0,1,0,0.0000713000,'US06City_extended';
%     0,0,1,0.0000713000,'US06City_extended';
%     1,0,0,0.0000920000,'US06HW_extended';
%     0,1,0,0.0000920000,'US06HW_extended';
%     0,0,1,0.0000920000,'US06HW_extended';
%     1,0,0,0.0001000000,'US06_extended';
%     0,1,0,0.0001000000,'US06_extended';
%     0,0,1,0.0001000000,'US06_extended';
%
%
%     % Best weights
%     0.95,0.97,0.81,0.0000002000,'FHDS_extended';
%     0.95,0.75,0.61,0.0000717000,'FUDS_extended';
%     0.78,0.81,0.0,0.0000996000,'FUDSfast_extended';
%     0.34,0.7,0.24,0.0000765000, 'NEDC_extended';
%     0.48,0.6,0.91,0.0000713000, 'US06City_extended';
%     0.7,1.0,0.26,0.0000920000, 'US06HW_extended';
%     1.0,1.0,0.0,0.0001000000, 'US06_extended';
%
%     };


% ================ FUDS, FUDS_FAST TEST ==========================
% data = {
%     % Test weights (Individual Cost)
%     1,0,0,0.0000002000,'FUDS_extended';
%     0,1,0,0.0000002000,'FUDS_extended';
%     0,0,1,0.0000002000,'FUDS_extended';
% 
%     1,0,0,0.0000002000,'FUDSfast_extended';
%     0,1,0,0.0000002000,'FUDSfast_extended';
%     0,0,1,0.0000002000,'FUDSfast_extended';
% 
% 
%     % Best weights
% 
%     0.95,0.97,0.81,0.0000002000,'FUDS_extended';
%     0.95,0.97,0.81,0.0000002000,'FUDSfast_extended';
% 
% 
%     };


% Input format: w1,w2,w3,wPL,DriveCycleName
% data = {
%     % Test weights (Individual Cost)
%     1,0,0,0.0000134000,'FHDS_extended';
%     0,1,0,0.0000134000,'FHDS_extended';
%     0,0,1,0.0000134000,'FHDS_extended';
%     1,0,0,0.0000380000,'FUDSfast_extended';
%     0,1,0,0.0000380000,'FUDSfast_extended';
%     0,0,1,0.0000380000,'FUDSfast_extended';
%     1,0,0,0.0000003000,'NEDC_extended';
%     0,1,0,0.0000003000,'NEDC_extended';
%     0,0,1,0.0000003000,'NEDC_extended';
%     1,0,0,0.0000003000,'FUDS_extended';
%     0,1,0,0.0000003000,'FUDS_extended';
%     0,0,1,0.0000003000,'FUDS_extended';
%     1,0,0,0.0000134000,'US06City_extended';
%     0,1,0,0.0000134000,'US06City_extended';
%     0,0,1,0.0000134000,'US06City_extended';
%     1,0,0,0.0000821000,'US06HW_extended';
%     0,1,0,0.0000821000,'US06HW_extended';
%     0,0,1,0.0000821000,'US06HW_extended';
%     1,0,0,0.0000870000,'US06_extended';
%     0,1,0,0.0000870000,'US06_extended';
%     0,0,1,0.0000870000,'US06_extended';
% 
% 
%     % Best weights
%     0.98,0.48,0.96,0.0000134000,'FHDS_extended';
%     0.16,0.06,0.87,0.0000003000,'FUDS_extended';
%     1.0,0.96,0.69,0.0000380000,'FUDSfast_extended';
%     0.16,0.06,0.87,0.0000003000,'NEDC_extended';
%     0.98,0.48,0.96,0.0000134000,'US06City_extended';
%     0.99,0.06,0.97,0.0000821000,'US06HW_extended';
%     0.99,0.4,0.99,0.0000870000,'US06_extended';
% 
%     };

% ================ US City, Highway ==========================
data = {
    % Test weights (Individual Cost)
    1,0,0,0.0000002000,'US06City_extended';
    0,1,0,0.0000002000,'US06City_extended';
    0,0,1,0.0000002000,'US06City_extended';

    1,0,0,0.0000002000,'US06HW_extended';
    0,1,0,0.0000002000,'US06HW_extended';
    0,0,1,0.0000002000,'US06HW_extended';


    % Best weights

    1.0,0.23,0.97,0.0000022000,'US06City_extended';
    1.0,0.23,0.97,0.0000022000,'US06HW_extended';


    };


% Extract weights and drive cycles
weights_set = cell2mat(data(:,1:4));
drive_cycles = data(:,5);

num_simulations = size(data, 1);
final_ranges = zeros(num_simulations,1);
final_sim_times = zeros(num_simulations,1);

for sim_idx = 1:num_simulations
    % Get current drive cycle and scaling factor
    DC = drive_cycles{sim_idx};
    if ~isKey(scaling_factors_map, DC)
        error('Drive cycle %s not found in scaling factors map', DC);
    end
    S_factor = scaling_factors_map(DC);

    % Get weights for current simulation
    current_weights = weights_set(sim_idx, :);
    w1 = current_weights(1);
    w2 = current_weights(2);
    w3 = current_weights(3);
    w_PL = current_weights(4);

    % Create weights vector in the workspace
    weights = [w1; w2; w3; w_PL];

    H=0.9;M=0.8;L=0.7;

    % Load the drive cycle data
    load(['CurrentVelocityData/', DC, '.mat']); % Assumes file contains 'i', 't', and 'vel'

    % Set up simulation data
    i_simulator = i;
    t_simulator = t;
    vel_simulator = vel;
    t_vel = t;

    % Scale current data
    i_simulator = S_factor * (i_simulator / max(i_simulator));

    % Create initial state vector
    x_0 = [H; M; L];

    % Set simulation final time
    tf = 19000;

    % Run the simulation using the Simulink model
    simout = sim('Range_ext_TCST_NoSDKF', tf);

    % Extract final range and simulation time
    if exist('range', 'var') && ~isempty(range)
        final_range = range(end);
    else
        final_range = NaN;
    end
    final_sim_time = t_sim(end);

    % Store results
    final_ranges(sim_idx) = final_range;
    final_sim_times(sim_idx) = final_sim_time;

    % Print the results for the current simulation
    fprintf('Drive Cycle: %s | w1=%.2f w2=%.2f w3=%.2f wPL=%.10f | Initial SOC (H=%.2f, M=%.2f, L=%.2f) | Final Range: %.2f | Final Sim Time: %.2f\n', ...
        DC, w1, w2, w3, w_PL, H, M, L, final_range, final_sim_time);
end

% Print a summary of all final ranges with weights
fprintf('\nSummary of Final Ranges and Weights for all drive cycles:\n');
for idx = 1:num_simulations
    fprintf('%s: w1:%.4f w2:%.4f w3:%.4f wPL:%.10f Range:%.2f\n', ...
        drive_cycles{idx}, ...
        weights_set(idx,1), weights_set(idx,2), weights_set(idx,3), weights_set(idx,4), ...
        final_ranges(idx));
end

toc