tic
clear
close all
clc

Stop_SOC = 0.1;  % Stop simulation when any cell's SOC reaches this
delta = 5;       % Step size for simulation

% Define drive cycle names, scaling factors, and fixed weights.
drive_cycles = {'FHDS_extended', 'FUDS_extended', 'FUDSfast_extended', 'NEDC_extended', 'US06City_extended', 'US06HW_extended', 'US06_extended'};
scaling_factors = [-2.5, -3.2, -5, -2.7, -5.7, -8, -8];

% Pre-defined weights [w1, w2, w3, wPL] for each drive cycle.
% weights_set = [...
%     0,1,0,0.0001000000;
%     1,0,0,0.0000710000;
%     1,0,0,0.0000160000;
%     1,0,0,0.0000980000;
%     1,0,0,0.0000950000;
%     1,0,0,0.0000920000;
%     1,0,0,0.0001000000;
%     ];
% weights_set = [...
%     0.34,0.35,0.69,0.0001;
%     0.94,0.93,0.27,0.0001;
%     0.07,0.5,0.93,0.0001;
%     0.0,1.0,0.0,0.0001;
%     0.6,0.98,0.03,0.0001;
%     0.73,1.0,0.0,0.0001;
%     0.71,1.0,1.0,0.0001;
%     ];
%

% Good
% weights_set = [...
%     0.74,0.89,0.12,0.0000710000;
%     0.95,0.75,0.61,0.0000717000;
%     0.78,0.81,0.0,0.0000996000;
%     0.34,0.7,0.24,0.0000765000;
%     0.48,0.6,0.91,0.0000713000;
%     0.04,0.26,0.84,0.0000555000;
%     0.94,0.51,0.4,0.0000191000;
%     ];


% weights_set = [...
%     0.34,0.94,0.12,0.0000713000;
%     0.39,0.75,0.24,0.0000715000;
%     0.33,0.95,0.12,0.0000192000;
%     0.04,0.75,0.15,0.0000551000;
%     0.04,0.26,0.15,0.0000555000;
%     0.94,0.6,0.95,0.0000968000;
%     0.94,0.51,0.4,0.0000197000;
%     ];

% Better
% weights_set = [...
%     0.95,0.97,0.81,0.0000002000;
%     0.99,0.56,0.45,0.0000032000;
%     0.53,0.3,0.02,0.0000169000;
%     0.99,0.97,0.52,0.0000013000;
%     0.75,0.5,0.5,0.0000012000;
%     0.95,0.97,0.81,0.0000002000;
%     0.94,0.27,0.46,0.0000008000;
%     ];


weights_set = [...
    0.95,0.97,0.81,0.0000002000;
    0.95,0.75,0.61,0.0000717000;
    0.78,0.81,0.0,0.0000996000;
    0.34,0.7,0.24,0.0000765000;
    0.48,0.6,0.91,0.0000713000;
    0.7,1.0,0.26,0.0000920000;
    1.0,1.0,0.0,0.0001000000;
    ];



num_simulations = length(drive_cycles);
final_ranges = zeros(num_simulations,1);
final_sim_times = zeros(num_simulations,1);

for sim_idx = 1:num_simulations
    % Get current drive cycle and scaling factor.
    DC = drive_cycles{sim_idx};
    S_factor = scaling_factors(sim_idx);

    % Get fixed weights for current simulation.
    current_weights = weights_set(sim_idx, :);
    w1 = current_weights(1);
    w2 = current_weights(2);
    w3 = current_weights(3);
    w_PL = current_weights(4);

    % Create weights vector in the workspace.
    weights = [w1; w2; w3; w_PL];

    H=0.9;M=0.8;L=0.7;

    % Load the drive cycle data.
    load(['CurrentVelocityData/', DC, '.mat']); % Assumes file contains 'i', 't', and 'vel'

    % Set up simulation data.
    i_simulator = i;
    t_simulator = t;
    vel_simulator = vel;
    t_vel = t;

    % Scale current data.
    i_simulator = S_factor * (i_simulator / max(i_simulator));

    % Create initial state vector.
    x_0 = [H; M; L];

    % Set simulation final time.
    tf = 19000;

    % Run the simulation using the Simulink model.
    % Ensure that your model is configured to use the workspace variables:
    % x_0, weights, i_simulator, t_simulator, etc.
    simout = sim('Range_ext_TCST_NoSDKF', tf);

    % Extract final range and simulation time.
    if exist('range', 'var') && ~isempty(range)
        final_range = range(end);
    else
        final_range = NaN;
    end
    final_sim_time = t_sim(end);

    % Store results.
    final_ranges(sim_idx) = final_range;
    final_sim_times(sim_idx) = final_sim_time;

    % Print the results for the current simulation.
    fprintf('Drive Cycle: %s | w1=%.2f w2=%.2f w3=%.2f wPL=%.10f | Initial SOC (H=%.2f, M=%.2f, L=%.2f) | Final Range: %.2f | Final Sim Time: %.2f\n', ...
        DC, w1, w2, w3, w_PL ,H, M, L, final_range, final_sim_time);
end

% Print a summary of all final ranges.
fprintf('\nSummary of Final Ranges for all drive cycles:\n');
for idx = 1:num_simulations
    fprintf('%s: %.2f\n', drive_cycles{idx}, final_ranges(idx));
end

toc
