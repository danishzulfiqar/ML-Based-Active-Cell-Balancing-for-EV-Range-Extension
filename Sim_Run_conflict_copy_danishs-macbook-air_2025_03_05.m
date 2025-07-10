tic
clear
close all
clc

%%
% pick any random value for initial SoCs~[0.5,0.9]
% H=0.9;M=0.8;L=0.6;
% H=0.7;M=0.6;L=0.5;
% H=0.7;M=0.95;L=0.85; same
H=0.9;M=0.8;L=0.7;
% H=0.45;M=0.65;L=0.98;
% H=0.45;M=0.98;L=0.65;

x_0=[H;M;L]; %intial state vector

Stop_SOC=0.1; % Stop simulation when any cell's SOC reaches this value
load('CurrentVelocityData/FHDS_extended.mat');
i_simulator=i;
t_simulator=t;
t_vel=t;
vel_simulator=vel;
i_simulator= -2.5 *(i_simulator/max(i_simulator)); %-3.2 is the scaling factor for FUDS_Extended
delta=5; %step size for simulation
w_PL=0.000052;

%The values of the weight matrix will be selected according to the
%discussed criterion a) w_L1, w_L2, w_L3 ~[0,1], and w_PL~[0,0.0001]
weights=[1.0;0;0;w_PL];% first value is the weight of cost L1, second is the weight for cost L2, third for cost L3 and the last or the power losses
%%
tf=19000;
simout=sim('Range_ext_TCST_NoSDKF',tf);
%MPC_KF is the complete file
%% main, CBN and SDKF
% save('US06_L1','t_sim','D1' ,'soc_M','J','I_cd',...
%   'v_t','PLoss','P_IO','I_b','I_cells', 'range');

% Display the final range and time
  if exist('range', 'var') && ~isempty(range)
    fprintf('Final range for H=%.2f, M=%.2f, L=%.2f : %.4f\n', H, M, L, range(end));
  else
    fprintf('Range not available for H=%.2f, M=%.2f, L=%.2f \n', H, M, L);
  end

  fprintf('Final simulation time: %.2f\n', t_sim(end));
%%
[range(end) t_sim(end)]


toc