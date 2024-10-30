clc;
clear;
close all;


% ---------------------- Load the dataset from a CSV file with headers -----------------------
data = readtable('./output_file.csv');

% Convert the table to a numeric array
dataArray = table2array(data);

% ------------------- Split the data into input weights (first 4 columns) and target range (last column) --------------------
X = dataArray(:, 1:4);  % 4 features (weights: w1, w2, w3, wpl)
Y = dataArray(:, 5);    % Target: Range

% Transpose the data to fit MATLAB's expected format for training
X = X';   % 4 rows (features) and N columns (samples)
Y = Y';   % 1 row, N columns (target values)

% ----------------------- Normalize the input data (weights) -----------------------
% Manually normalize the input data to have zero mean and unit variance
X_mean = mean(X, 2);       % Compute the mean along each row for X
X_std = std(X, 0, 2);      % Compute the standard deviation along each row for X
X = (X - X_mean) ./ X_std; % Normalize the data

% ----------------------- Normalize the target data (range) -----------------------
% Manually normalize the target data to have zero mean and unit variance
Y_mean = mean(Y, 2);       % Compute the mean along each row for Y
Y_std = std(Y, 0, 2);      % Compute the standard deviation along each row for Y
Y = (Y - Y_mean) ./ Y_std; % Normalize the data

% Get the number of samples
numSamples = size(X, 2);

% ----------------------- Split the data into 80% training and 20% testing -----------------------
trainSize = round(0.8 * numSamples);
indices = randperm(numSamples);

% Training data
X_train = X(:, indices(1:trainSize));
Y_train = Y(:, indices(1:trainSize));

% Testing data
X_test = X(:, indices(trainSize+1:end));
Y_test = Y(:, indices(trainSize+1:end));

% -------------- Create a feedforward network with 10 neurons in 1 hidden layer -----------------
    net = feedforwardnet(50);

% ---------------- Configure training parameters -------------------------
% Set the maximum number of epochs
net.trainParam.epochs = 1000; % Maximum number of iterations

% Set the performance goal
net.trainParam.goal = 1e-6; % Training will stop if the performance is below this value

% Set the maximum number of validation checks for early stopping
net.trainParam.max_fail = 100; % Stop training if the validation error increases for 6 consecutive epochs

% Set the learning rate
net.trainParam.lr = 0.001;

% Set the minimum gradient for stopping criteria
net.trainParam.min_grad = 1e-7;

% Set the maximum training time (in seconds)
net.trainParam.time = 300; % Training will stop after 300 seconds

% Choose the training function (Levenberg-Marquardt backpropagation)
net.trainFcn = 'trainlm';

% Set the performance function (Mean Squared Error)
net.performFcn = 'mse';

% Configure data division (70% training, 15% validation, 15% testing)
net.divideParam.trainRatio = 80/100; % 80% training data
net.divideParam.valRatio = 10/100;   % 10% validation data
net.divideParam.testRatio = 10/100;  % 10% testing data
    

% Train the network
[net, tr] = train(net, X_train, Y_train);

% Save the trained model to a .mat file
save('trained_network.mat', 'net');
disp('Trained network has been saved to trained_network.mat');

% Predict the range using the trained network
predicted_ranges = net(X_test);

% ----------------------------- Evaluating results --------------------------------------------
disp('Predicted Ranges:');
disp(predicted_ranges);

% Compare actual weights and predicted ranges for the test set
disp('Weights (w1, w2, w3, wpl) with Actual and Predicted Ranges:');
weights_actual_predicted = [X_test' Y_test' predicted_ranges'];  % Combine weights, actual, and predicted ranges
disp('Columns: w1, w2, w3, wpl, Actual Range, Predicted Range');
disp(weights_actual_predicted);

% Save results to a CSV file
csvwrite('predicted_ranges.csv', predicted_ranges');

% Save results to an Excel file
writematrix(predicted_ranges', 'predicted_ranges.xlsx');


% -------------------- Calculate accuracy metrics -------------------------
% % Mean Squared Error (MSE)
% mseValue = mean((Y_test - predicted_ranges).^2);
% disp(['Mean Squared Error (MSE): ', num2str(mseValue)]);
% 
% % Mean Absolute Error (MAE)
% maeValue = mean(abs(Y_test - predicted_ranges));
% disp(['Mean Absolute Error (MAE): ', num2str(maeValue)]);
% 
% % R-squared (Coefficient of Determination)
% ssRes = sum((Y_test - predicted_ranges).^2);
% ssTot = sum((Y_test - mean(Y_test)).^2);
% rSquared = 1 - (ssRes / ssTot);
% disp(['R-squared: ', num2str(rSquared)]);

% Plot the performance
plotperform(tr);

% Optional: Display the network architecture
view(net);
