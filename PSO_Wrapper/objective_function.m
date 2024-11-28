function fitness = objective_function(weights)
w1 = weights(1);
w2 = weights(2);
w3 = weights(3);
w_PL = weights(4);

% Normalize weights
weights_sum = sum(weights(1:3));
if weights_sum > 0
    w1 = w1 / weights_sum;
    w2 = w2 / weights_sum;
    w3 = w3 / weights_sum;
end

% Load the required drive cycle
DC = 'FHDS_extended';
load(['CurrentVelocityData/', DC, '.mat']);

% Scaling factor
S_factor = -2.5;
i_simulator = (S_factor) * (i / max(i));

% Initial state of charge
H = 0.8; M = 0.7; L = 0.6;
x_0 = [H; M; L];

% Run the Simulink model
try
    tf = 19000;
    simout = sim('Range_ext_TCST_NoSDKF', tf);

    % Extract range from simulation output
    if exist('range', 'var') && ~isempty(range)
        fitness = -range(end); % Negative because PSO minimizes fitness
    else
        fitness = 1e3; % penalty
    end
catch
    % Penalty for simulation errors
    fitness = 1e3;
end
end