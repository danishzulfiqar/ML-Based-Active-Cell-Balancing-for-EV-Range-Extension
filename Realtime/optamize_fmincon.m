clc
clear
close all

% Define the objective function
objective = @(x) -test_model(x(1), x(2), x(3), x(4), 'FHDS_extended');
% Note: We negate the output because we want to maximize, but fmincon minimizes

% Lower and upper bounds for weights
lb = [0, 0, 0, 0];
ub = [1, 1, 1, 0.0001];

% Initial guess (middle of the range for each variable)
x0 = [(lb(1)+ub(1))/2, (lb(2)+ub(2))/2, (lb(3)+ub(3))/2, (lb(4)+ub(4))/2];

% Linear constraint (sum of first three weights should be 1)
A = [1 1 1 0];
b = 1;

% Options for fmincon
options = optimoptions('fmincon', 'Display', 'iter', 'MaxFunctionEvaluations', 100);

% Run the optimization
[x_opt, fval] = fmincon(objective, x0, A, b, [], [], lb, ub, [], options);

% Display results
disp('Best weights found:');
disp(['w1: ', num2str(x_opt(1))]);
disp(['w2: ', num2str(x_opt(2))]);
disp(['w3: ', num2str(x_opt(3))]);
disp(['wPL: ', num2str(x_opt(4))]);
disp(['Maximum range: ', num2str(-fval)]);  % Remember to negate back