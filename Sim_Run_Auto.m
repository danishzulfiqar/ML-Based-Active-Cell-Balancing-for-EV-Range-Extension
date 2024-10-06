tic
clear
close all
clc


Sim_Num = 5;  % Number of simulations to run

Stop_SOC = 0.1;  % Stop simulation when any cell's SOC reaches this


drive_cycles = {'FHDS_extended', 'FUDS_extended', 'FUDSfast_extended', 'NEDC_extended', 'US06City_extended',  'US06HW_extended', 'US06_extended'};
scalling_factors = [-2.5, -3.2 , -5 , -2.7, -5.7, -8, -8];


%% Load the drive cycle data for the first drive cycle
load(['CurrentVelocityData/', drive_cycles{1}, '.mat']);  % Correct MATLAB indexing


i_simulator = i;
t_simulator = t;
t_vel = t;
vel_simulator = vel;


S_factor = scalling_factors(1);

i_simulator = (S_factor) * (i_simulator / max(i_simulator)); 

delta = 5;  % Step size for simulation

w_PL = 0.0001;  % Weight for power losses

%% Loop through each simulation
for sim_idx = 1:Sim_Num

  L = round(rand * 10) / 10;
  M = round(rand * 10) / 10;
  H = round(rand * 10) / 10;

  % --------------------------------------
  % sorted_SOC = sort([L, M, H]);
  % L = sorted_SOC(1);
  % M = sorted_SOC(2);
  % H = sorted_SOC(3);
  % --------------------------------------

  % Assign 1 to a random weight and 0 to the others
  weights_array = [0, 0, 0];
  random_index = randi(3);
  weights_array(random_index) = 1;

  w1 = weights_array(1);  % Weight for cost L1
  w2 = weights_array(2);  % Weight for cost L2
  w3 = weights_array(3);  % Weight for cost L3

  weights = [w1; w2; w3; w_PL];  % Weights for cost L1, L2, L3, and power losses


  % Initial state vector
  x_0 = [H; M; L];  % Initial state vector for SOC

  % Set the total simulation time
  tf = 19000;

  % Run the simulation using the Simulink model
  simout = sim('Range_ext_TCST_NoSDKF', tf);

  % Save the simulation results
  save_filename = sprintf('GeneratedData/Simulation_SOC_H%.2f_M%.2f_L%.2f_w1_%d_w2_%d_w3_%d_Sim%d.mat', H, M, L, w1, w2, w3, sim_idx);
  save(save_filename, 't_sim', 'D1', 'soc_M', 'J', 'I_cd', ...
    'v_t', 'PLoss', 'P_IO', 'I_b', 'I_cells', 'range');

  % Display the final range and time
  if exist('range', 'var') && ~isempty(range)
    fprintf('Final range for H=%.2f, M=%.2f, L=%.2f (Simulation %d): %.2f\n', H, M, L, sim_idx, range(end));
  else
    fprintf('Range not available for H=%.2f, M=%.2f, L=%.2f (Simulation %d)\n', H, M, L, sim_idx);
  end

  fprintf('Final simulation time: %.2f\n', t_sim(end));

end

toc
