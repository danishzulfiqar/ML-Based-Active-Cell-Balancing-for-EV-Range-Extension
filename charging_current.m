function I_ch = charging_current(u,H_OCV,R0,L)
%% Constant Model Parameters 
sf=50e3;    %Hz, switching frequency
td=2e-6;    %[s], dead time
sT=1/sf;    %[s], time period
Rds_on = 5.3e-3; % MOSFET resistance when it is on

%Balancing architecture
R_L = 10e-3; %parasitic resitance of the inductor
R_ch=R0+R_L+Rds_on; %Charging path resistance, when higher SoC cell charges the inductor
tau_ch=L/R_ch; %[s], charging time constant
%%
I_ch=-(H_OCV/(sT*R_ch)*(u*sT-td)+tau_ch*(exp(-(u*sT-td)/tau_ch)-1)*H_OCV/(sT*R_ch));
end