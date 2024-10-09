tic
clear
close all
clc

Sim_Num = 14;  % Number of simulations to run
Stop_SOC = 0.1;  % Stop simulation when any cell's SOC reaches this
delta = 5;  % Step size for simulation

% Drive cycle names and scaling factors
drive_cycles = {'FHDS_extended', 'FUDS_extended', 'FUDSfast_extended', 'NEDC_extended', 'US06City_extended', 'US06HW_extended', 'US06_extended'};
scaling_factors = [-2.5, -3.2, -5, -2.7, -5.7, -8, -8];

% Loop through each simulation
for sim_idx = 1:Sim_Num

  % Get the correct drive cycle index for each simulation
  drive_cycles_index = mod(sim_idx - 1, length(drive_cycles)) + 1;  % Ensure index wraps around

  % ---------------------- Randomly generate SOC values between 0.5 and 0.9 ----------------------
  L = 0.5 + (0.9 - 0.5) * rand;
  M = 0.5 + (0.9 - 0.5) * rand;
  H = 0.5 + (0.9 - 0.5) * rand;

  % Round the values to one decimal place
  L = round(L * 10) / 10;
  M = round(M * 10) / 10;
  H = round(H * 10) / 10;

  DC = drive_cycles{drive_cycles_index};

  % ------------------------- Load the drive cycle data  -------------------------
  load(['CurrentVelocityData/', DC, '.mat']);

  i_simulator = i;
  t_simulator = t;
  t_vel = t;
  vel_simulator = vel;

  % Apply the corresponding scaling factor
  S_factor = scaling_factors(drive_cycles_index);

  i_simulator = (S_factor) * (i_simulator / max(i_simulator));

  %  ---------------- Randomly assign one of the weights to 1 and the others to 0 ----------------
  w_PL = 0.0001;  % Weight for power losses -- max value 0.0001 (0 - 0.0001)
  weights_array = [0, 0, 0];
  random_index = randi(3);
  weights_array(random_index) = 1;

  w1 = weights_array(1);  % Weight for cost L1
  w2 = weights_array(2);  % Weight for cost L2
  w3 = weights_array(3);  % Weight for cost L3

  weights = [w1; w2; w3; w_PL];  % Weights for cost L1, L2, L3, and power losses

  % Initial state vector
  x_0 = [H; M; L];

  % Set the total simulation time
  tf = 19000;

  % Run the simulation using the Simulink model
  simout = sim('Range_ext_TCST_NoSDKF', tf);

  % Save the simulation results
  save_filename = sprintf('GeneratedData/Simulation_DC_%s_SF_%.2f_SOC_H%.2f_M%.2f_L%.2f_w1_%d_w2_%d_w3_%d_Sim%d.mat',  DC , S_factor , H, M, L, w1, w2, w3, sim_idx);
  save(save_filename, 't_sim', 'D1', 'soc_M', 'J', 'I_cd', 'v_t', 'PLoss', 'P_IO', 'I_b', 'I_cells', 'range');

  % Display the final range and time
  if exist('range', 'var') && ~isempty(range)
    fprintf('Final range for H=%.2f, M=%.2f, L=%.2f (Simulation %d): %.2f\n', H, M, L, sim_idx, range(end));
  else
    fprintf('Range not available for H=%.2f, M=%.2f, L=%.2f (Simulation %d)\n', H, M, L, sim_idx);
  end

  fprintf('Final simulation time: %.2f\n', t_sim(end));

end

toc
