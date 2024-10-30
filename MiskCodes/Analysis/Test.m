clc;
clear;
close all;

% Load the dataset from a CSV file with headers
data = readtable('output_file.csv');

% Convert the table to a numeric array
dataArray = table2array(data);

% Normalize inputs and outputs using mapminmax
[X, Xsettings] = mapminmax(dataArray(:, 1:4)', 0, 1);  % Normalize input features to [0, 1]
[Y, Ysettings] = mapminmax(dataArray(:, 5)', 0, 1);    % Normalize target variable to [0, 1]

% Set display format to long for better precision
format long;

% Create a simpler network with one hidden layer of 20 neurons
net = feedforwardnet([10, 30]);

% Set the training function to Resilient Backpropagation
net.trainFcn = 'trainrp';

% Enable data division for validation and testing
net.divideFcn = 'divideblock';
net.divideParam.trainRatio = 0.8;   % 80% training data
net.divideParam.testRatio = 0.2;    % 20% testing data

% Custom training parameters
net.trainParam.epochs = 1000;       % Maximum number of training epochs
net.trainParam.goal = 0.001;        % Target mean squared error
net.trainParam.min_grad = 1e-6;     % Minimum gradient threshold
net.trainParam.max_fail = 300;      % Increased validation patience

% Train the neural network
[net, tr] = train(net, X, Y);

% Predict and save results
predicted_ranges = net(X);

% Denormalize the input features
X_denorm = mapminmax('reverse', X, Xsettings);

% Denormalize the predicted ranges
predicted_ranges_denorm = mapminmax('reverse', predicted_ranges, Ysettings);

% Denormalize the actual Y values for comparison
Y_denorm = mapminmax('reverse', Y, Ysettings);

% Prepare output table with denormalized values
outputTable = array2table([X_denorm' Y_denorm' predicted_ranges_denorm'], ...
    'VariableNames', {'w1', 'w2', 'w3', 'wpl', 'Actual_Range', 'Predicted_Range'});

% Save the results to an Excel file
writetable(outputTable, 'predicted_ranges_with_trainrp.xlsx');

% Calculate performance metrics using denormalized data
Y_denorm = Y_denorm';  % Transpose to match predicted output dimensions
predicted_ranges_denorm = predicted_ranges_denorm';

MAE = mean(abs(Y_denorm - predicted_ranges_denorm));           % Mean Absolute Error
MSE = mean((Y_denorm - predicted_ranges_denorm).^2);           % Mean Squared Error
RMSE = sqrt(MSE);                                              % Root Mean Square Error
R_squared = 1 - sum((Y_denorm - predicted_ranges_denorm).^2) / sum((Y_denorm - mean(Y_denorm)).^2);  % R-squared

% Display the results in the command window
disp('Performance Metrics:');
disp(['Mean Absolute Error (MAE): ', num2str(MAE)]);
disp(['Mean Squared Error (MSE): ', num2str(MSE)]);
disp(['Root Mean Square Error (RMSE): ', num2str(RMSE)]);
disp(['R-squared (R^2): ', num2str(R_squared)]);

% Plot performance
plotperform(tr);
view(net);
