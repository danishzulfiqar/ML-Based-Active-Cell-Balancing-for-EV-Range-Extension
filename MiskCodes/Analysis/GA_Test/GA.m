clc
clear
close all

objFunc = @(vars) (vars(1) - 2)^2 + (vars(2) + 3)^2;

nVars = 2;

lb = [-10, -10]; % Lower bounds for x and y
ub = [10, 10];   % Upper bounds for x and y

% ---------------------- GA options ---------------------
options = optimoptions('ga', 'Display', 'iter', 'PlotFcn', @gaplotbestf);


[x_opt, fval] = ga(objFunc, nVars, [], [], [], [], lb, ub, [], options);

% Display the results
fprintf('The optimal values are x = %.4f and y = %.4f\n', x_opt(1), x_opt(2));
fprintf('The minimum value of the objective function is %.4f\n', fval);
