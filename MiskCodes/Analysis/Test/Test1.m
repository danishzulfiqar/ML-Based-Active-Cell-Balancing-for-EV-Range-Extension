clc
clear
close all

% Sample Data
% Generate some sample input (X) and output (Y) data
% In practice, replace this with your actual data
X = linspace(-10, 10, 100); % 100 input samples from -10 to 10
Y = sin(X) + 0.1 * randn(size(X)); % Generate output with some noise

% Reshape the data for the neural network
X = X'; % Convert to column vector
Y = Y'; % Convert to column vector

% Create and configure the feedforward neural network
hiddenLayerSizes = [20, 15, 10]; % Three hidden layers with 20, 15, and 10 neurons
net = feedforwardnet(hiddenLayerSizes, 'trainlm'); % Create the network with Levenberg-Marquardt training

% Configure training parameters for higher accuracy
net.trainParam.epochs = 2000; % Increase the number of training epochs
net.trainParam.goal = 1e-7; % Set a lower training goal for higher accuracy
net.trainParam.max_fail = 10; % Increase maximum validation failures

% Divide the data for training, validation, and testing
net.divideParam.trainRatio = 70/100; % 70% for training
net.divideParam.valRatio = 15/100;   % 15% for validation
net.divideParam.testRatio = 15/100;  % 15% for testing

% Train the neural network
[net, tr] = train(net, X', Y'); % Train using input and target data

% Test the trained network
Y_pred = net(X'); % Predict using the trained network

% Calculate performance metrics
performance = perform(net, Y', Y_pred); % Mean squared error

% Plot the results
figure;
plot(X, Y, 'b', 'LineWidth', 1.5); % Plot actual output
hold on;
plot(X, Y_pred, 'r--', 'LineWidth', 1.5); % Plot predicted output
xlabel('Input');
ylabel('Output');
title(['Neural Network Output vs. Real Output (MSE: ' num2str(performance) ')']);
legend('Real Output', 'Model Output');
grid on;

% Plot the training state (performance)
figure;
plotperform(tr);
title('Training Performance');

% Plot regression (actual vs. predicted)
figure;
plotregression(Y', Y_pred);
title('Regression (Actual vs. Predicted)');
