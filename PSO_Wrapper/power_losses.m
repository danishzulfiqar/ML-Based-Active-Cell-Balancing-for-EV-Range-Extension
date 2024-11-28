function [P_cond_1,P_sw_1,P_td_1,P_R_1]=power_losses(u,H_OCV,L_OCV,L)
%% Constant Model Parameters 
sf=50e3;    %Hz, switching frequency
td=2e-6;    %[s], dead time
sT=1/sf;    %[s], time period
Vf = 0.3;   %[V], Diode forward voltage drop
Rds_on = 5.3e-3; % MOSFET resistance when it is on

%Switches parameters
tfall=8e-9;
trr=28e-9;

%Balancing architecture
R_L = 10e-3; %parasitic resitance of the inductor
R_dis=R_L; %Discharging path resistance, when inductor charges low SoC cell
R_ch=R_L+Rds_on; %Charging path resistance, when higher SoC cell charges the inductor

tau_dis=L/R_dis; %[s], discharging time constant
tau_ch=L/R_ch; %[s], charging time constant
%% 
%RMS current during charging of inductor
I_ch_rms= sqrt(abs(H_OCV^2/(sT*R_ch^2)*(tau_ch*exp((td-u*sT)/tau_ch)...
            *(4-exp((td-u*sT)/tau_ch))/2+u*sT-td-(3*tau_ch/2))));
I_ch_rms=real(I_ch_rms);   

%RMS current during discharging of inductor
tf=sT*(u+tau_dis/sT*log(1+R_dis*H_OCV/((L_OCV+Vf)*R_ch)*(1-exp(-(u*sT-td)/tau_ch)))); 
  
% Equation 18 discharging of the inductor
I_max=H_OCV/R_ch*(1-exp(-((u*sT-td)/tau_ch)));  
I_dis=1/sT*(-tau_dis*I_max*(exp(-(tf-u*sT)/tau_dis)-1)-(L_OCV+Vf)/R_dis... 
  *(tf-u*sT+tau_dis*(exp(-(tf-u*sT)/tau_dis)-1))); 
I_d_rms= sqrt(abs(1/sT*(exp(-(tf-u*sT)/tau_dis)...
           *(2*I_max*( (L_OCV+Vf)/R_dis)*tau_dis+2*...
           ((L_OCV+Vf)/R_dis)^2*tau_dis)-exp(-2*(tf-u*sT)/tau_dis)*...
           (tau_dis*I_max^2/2+((L_OCV+Vf)/R_dis)^2*tau_dis/2+I_max*...
           ((L_OCV+Vf)/R_dis)*tau_dis)-3/2*((L_OCV+Vf)/R_dis)^2*...
           tau_dis-I_max*((L_OCV+Vf)/R_dis)*tau_dis+tau_dis*I_max^2/2+...
           ((L_OCV+Vf)/R_dis)^2*(tf-u*sT) )));
 I_d_rms=real(I_d_rms); 
D3=(tf-u*sT-2*td)/sT;% Effective Duty cyle from DT+2td to tf
%%

%Conduction, switching and dead time losses
P_cond_1=(I_ch_rms^2*R_ch)*u+(I_d_rms^2*R_dis)*(D3);
P_sw_1=0.5/sT*H_OCV*I_dis*tfall;
P_td_1=0.5/sT*Vf*I_dis*td;

di_dt=(L_OCV+Vf)/L;
Qrr=0.5*di_dt*trr^2;
IRR=sqrt(abs(2*Qrr*di_dt));

P_R_1=0.5/sT*L_OCV*IRR*trr;
end


