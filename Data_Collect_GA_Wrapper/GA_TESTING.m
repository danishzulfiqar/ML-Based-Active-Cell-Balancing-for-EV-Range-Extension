%% Set up variables and GA options
nvars = 4;  % Number of weights

% Lower and upper bounds for weights
lb = [0, 0, 0, 0];
ub = [1, 1, 1, 0.0001];

% GA options (adjust as needed)
options = optimoptions('ga', ...
    'PopulationSize', 3, ...          
    'MaxGenerations', 2, ...         
    'CrossoverFraction', 0.8, ...      
    'MutationFcn', {@mutationuniform, 0.1}, ... 
    'Display', 'iter', ...             
    'UseParallel', false);

% Drive cycle names and corresponding scaling factors
drive_cycles = {'FHDS_extended', 'FUDS_extended', 'FUDSfast_extended', ...
                'NEDC_extended', 'US06City_extended', 'US06HW_extended', 'US06_extended'};
scaling_factors = [-2.5, -3.2, -5, -2.7, -5.7, -8, -8];

numCycles = length(drive_cycles);
numIterations = 50;

%% Open CSV file for continuous writing
fid = fopen('GA_Results.csv','w');
if fid == -1
    error('Could not open file for writing.');
end

% Write header line
fprintf(fid, 'Iteration,w1,w2,w3,wPL,DC,Range\n');

globalCount = 0;  % Global iteration counter

%% Loop over each drive cycle and run GA optimization for numIterations
for dcIdx = 1:numCycles
    DC = drive_cycles{dcIdx};
    S_factor = scaling_factors(dcIdx);
    fprintf('--- Optimizing for drive cycle: %s ---\n', DC);
    
    for iter = 1:numIterations
         % Create objective function handle with extra parameters
         objFun = @(weights) objective_function(weights, DC, S_factor);
         
         % Run GA for this iteration
         [optWeights, fval] = ga(objFun, nvars, [], [], [], [], lb, ub, [], options);
         
         % Compute the final range (assuming objective_function returns -range)
         finalRange = -fval;
         
         % Write this result to the CSV file immediately
         fprintf(fid, '%d,%.4f,%.4f,%.4f,%.6f,%s,%.6f\n',...
             globalCount, optWeights(1), optWeights(2), optWeights(3), optWeights(4), DC, finalRange);
         
         fprintf('Global Iteration %d: [%.4f, %.4f, %.4f, %.6f] on %s -> Range = %.6f\n',...
             globalCount, optWeights(1), optWeights(2), optWeights(3), optWeights(4), DC, finalRange);
         
         globalCount = globalCount + 1;
         % No fflush; MATLAB writes output automatically.
    end
end

%% Close the CSV file
fclose(fid);
fprintf('Results continuously written to GA_Results.csv\n');
