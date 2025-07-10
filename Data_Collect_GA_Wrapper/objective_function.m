function fitness = objective_function(weights, DC, S_factor)
% Unpack weights
w1 = weights(1);
w2 = weights(2);
w3 = weights(3);
w_PL = weights(4);

% Normalize first three weights (if sum > 0)
weights_sum = sum(weights(1:3));
if weights_sum > 0
    w1 = w1 / weights_sum;
    w2 = w2 / weights_sum;
    w3 = w3 / weights_sum;
end

% Check bounds (should be satisfied by GA, but extra safety)
lb = [0, 0, 0, 0];
ub = [1, 1, 1, 0.0001];
if any(weights < lb) || any(weights > ub)
    fitness = 1e6;
    return;
end

% Load drive cycle data (ensure file exists)
load(['CurrentVelocityData/', DC, '.mat']); % expects variables i, t, vel

% Scale current data using S_factor
i_simulator = S_factor * (i / max(i));

% Define initial state-of-charge (example values)
H = 0.8; M = 0.7; L = 0.6;
x_0 = [H; M; L];

% Set total simulation time
tf = 19000;

% Run the Simulink model (assumes it picks up x_0, i_simulator, etc.)
try
    simout = sim('Range_ext_TCST_NoSDKF', tf);
    if exist('range', 'var') && ~isempty(range)
        % Return negative of the final range so that GA minimizes -range
        fitness = -range(end);
    else
        fitness = 1e3;  % penalty if range not available
    end
catch
    fitness = 1e3;  % penalty on simulation error
end
end
