clc
clear
close all

% Load the dataset from a CSV file with headers
data = readtable('../output_file.csv');

% Convert the table to a numeric array
dataArray = table2array(data);
% Normalize inputs and outputs using mapminmax
X = mapminmax(dataArray(:, 1:4)', 0, 1);  % Normalize input features to [0, 1]
Y = mapminmax(dataArray(:, 5)', 0, 1);    % Normalize target variable to [0, 1]

% Set display format to long for better precision
format long;

%rng(0); % Set random seed for reproducibility

% Create a simpler network with one hidden layer of 20 neurons
net = feedforwardnet(130);

% Set the training function to Resilient Backpropagation
net.trainFcn = 'trainrp';


% Enable data division for validation and testing
net.divideFcn = 'divideblock';
net.divideParam.trainRatio = 0.8;   % 70% training data
net.divideParam.testRatio = 0.2;   % 15% testing data

% Custom training parameters
net.trainParam.epochs = 8000;       % Maximum number of training epochs
net.trainParam.goal = 0.01;          % Target mean squared error
net.trainParam.min_grad = 1e-6;      % Minimum gradient threshold
net.trainParam.max_fail = 2000;        % Increased validation patience
net.performParam.regularization = 0.02; % Example L2 regularization
% Train the neural network
[net, tr] = train(net, X, Y);

% Predict and save results
predicted_ranges = net(X);
outputTable = array2table([X' Y' predicted_ranges'], ...
    'VariableNames', {'w1', 'w2', 'w3', 'wpl', 'Actual_Range', 'Predicted_Range'});
writetable(outputTable, 'predicted_ranges_with_trainrp.xlsx');
% Calculate performance metrics
Y = Y';  % Transpose to match predicted output dimensions
predicted_ranges = predicted_ranges';

MAE = mean(abs(Y - predicted_ranges));           % Mean Absolute Error
MSE = mean((Y - predicted_ranges).^2);           % Mean Squared Error
RMSE = sqrt(MSE);                                % Root Mean Square Error
R_squared = 1 - sum((Y - predicted_ranges).^2) / sum((Y - mean(Y)).^2);  % R-squared

% Display the results in the command window
disp('Performance Metrics:');
disp(['Mean Absolute Error (MAE): ', num2str(MAE)]);
disp(['Mean Squared Error (MSE): ', num2str(MSE)]);
disp(['Root Mean Square Error (RMSE): ', num2str(RMSE)]);
disp(['R-squared (R^2): ', num2str(R_squared)]);
% Plot performance
plotperform(tr);
view(net);
 %Plot the actual and predicted values as lines
figure;
plot(Y, 'b-', 'LineWidth', 1.5);           % Plot actual values as a blue line
hold on;
plot(predicted_ranges, 'r--', 'LineWidth', 1.5); % Plot predicted values as a red dashed line
xlabel('Sample');
ylabel('Normalized Range');
legend('Actual Range', 'Predicted Range');
title('Comparison of Actual and Predicted Ranges');
grid on;