function range = test_model(w1, w2, w3, wPL, DC)
    % Initialize variables
    Stop_SOC = 0.1; % Stop simulation when any cell's SOC reaches this
    delta = 5; % Step size for simulation

    % Drive cycle names and scaling factors
    drive_cycles = {'FHDS_extended', 'FUDS_extended', 'FUDSfast_extended', 'NEDC_extended', 'US06City_extended', 'US06HW_extended', 'US06_extended'};
    scaling_factors = [-2.5, -3.2, -5, -2.7, -5.7, -8, -8];

    % Find the index of the provided DC in drive_cycles
    drive_cycles_index = find(strcmp(drive_cycles, DC));
    if isempty(drive_cycles_index)
        error('Invalid drive cycle provided');
    end

    H = 0.9; M = 0.8; L = 0.7;

    % Load the drive cycle data
    load(['CurrentVelocityData/', DC, '.mat']);
    S_factor = scaling_factors(drive_cycles_index);
    
    % Ensure i is a column vector with the same length as t
    if size(i, 1) ~= size(t, 1)
        i = interp1(linspace(0, 1, length(i)), i, linspace(0, 1, length(t)))';
    end
    
    i_simulator = (S_factor) * (i / max(i));
    vel_simulator = vel;

    % Create weights array
    weights = [w1; w2; w3; wPL]; % Weights for cost L1, L2, L3, and power losses

    % Initial state vector
    x_0 = [H; M; L];

    % Set the total simulation time
    tf = 19000;

    % Load the Simulink model
    model = 'Range_ext_TCST_NoSDKF';
    load_system(model);

    % Create a SimulationInput object
    simIn = Simulink.SimulationInput(model);

    % Set model parameters using the SimulationInput object
    simIn = simIn.setBlockParameter([model '/Cell Balancing Network/Integrator'], 'InitialCondition', mat2str(x_0));
    simIn = simIn.setVariable('t_simulator', t);
    simIn = simIn.setVariable('i_simulator', i_simulator);
    simIn = simIn.setVariable('t_vel', t);
    simIn = simIn.setVariable('vel_simulator', vel_simulator);
    simIn = simIn.setVariable('Stop_SOC', Stop_SOC);
    simIn = simIn.setBlockParameter([model '/W'], 'Value', mat2str(weights));
    simIn = simIn.setBlockParameter([model '/ZOH'], 'SampleTime', num2str(delta));
    simIn = simIn.setModelParameter('StopTime', num2str(tf));

    % Run the simulation
    simout = sim(simIn);

    % Extract the range from the simulation output
    if ~isempty(simout.get('range'))
        range_data = simout.get('range');
        final_range = range_data(end);

    else
        error('Range not available from simulation');
    end

    % Close the model
    close_system(model, 0);

    % Print weights, range, and DC
    fprintf('Drive Cycle: %s\n', DC);
    fprintf('Weights: w1 = %.4f, w2 = %.4f, w3 = %.4f, wPL = %.6f\n', w1, w2, w3, wPL);
    fprintf('Range: %.2f\n', final_range);
    
    
    % Save results to CSV file
    filename = 'optimization_results.csv';
    if ~isfile(filename)
        % Create the file with headers if it doesn't exist
        header = {'w1', 'w2', 'w3', 'wPL', 'DC', 'range'};
        writecell(header, filename);
    end
    
    % Append the new data
    new_data = {w1, w2, w3, wPL, DC, final_range};
    writecell(new_data, filename, 'WriteMode', 'append');

    % Return the final range
    range = final_range;
end