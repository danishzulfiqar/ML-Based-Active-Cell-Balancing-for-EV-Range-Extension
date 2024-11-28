function I_dis = discharging_current(u,H_OCV,L_OCV,R0,L)
%% Constant Model Parameters 
R01=R0(1);
R02=R0(2);
sf=50e3;    %Hz, switching frequency
td=2e-6;    %[s], dead time
sT=1/sf;    %[s], time period
Vf = 0.3;   %[V], Diode forward voltage drop
Rds_on = 5.3e-3; % MOSFET resistance when it is on

%Balancing architecture
R_L = 10e-3; %parasitic resitance of the inductor
R_dis=R02+R_L; %Discharging path resistance, when inductor charges low SoC cell
R_ch=R01+R_L+Rds_on; %Charging path resistance, when higher SoC cell charges the inductor

tau_dis=L/R_dis; %[s], discharging time constant
tau_ch=L/R_ch; %[s], charging time constant

%%
I_max=H_OCV/R_ch*(1-exp(-((u*sT-td)/tau_ch)));   
% time instant at which inductor current becomes zero labeled as t0 in figure 6
tf=sT*(u+tau_dis/sT*log(1+R_dis*H_OCV/((L_OCV+Vf)*R_ch)*(1-exp(-(u*sT-td)/tau_ch)))); 
  
% Equation 18 discharging of the inductor
I_dis=1/sT*(-tau_dis*I_max*(exp(-(tf-u*sT)/tau_dis)-1)-(L_OCV+Vf)/R_dis... 
  *(tf-u*sT+tau_dis*(exp(-(tf-u*sT)/tau_dis)-1)));

end