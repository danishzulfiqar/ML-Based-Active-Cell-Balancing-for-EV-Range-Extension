classdef Range_Max_2 < matlab.System & matlab.system.mixin.Propagates
    % untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    properties
        % Public, tunable properties.

    end

    properties (DiscreteState)
    end

    properties (Access = private)
        % Pre-computed constants.
        casadi_solver
        x0
        lbx
        ubx
        lbg
        ubg
    end

    methods (Access = protected)
        function num = getNumInputsImpl(~)
            num = 3;
        end
        function num = getNumOutputsImpl(~)
            num = 5; %1;
        end
        function [dt1,dt2,dt3,dt4,dt5] = getOutputDataTypeImpl(~)
        	dt1 = 'double';
            dt2 = 'double';
            dt3 = 'double';
            dt4 = 'double';
            dt5 = 'double';
                        end
        function [dt1,dt2,dt3] = getInputDataTypeImpl(~)
        	dt1 = 'double';
            dt2 = 'double';
            dt3 = 'double';
             end
        function [sz1,sz2,sz3,sz4,sz5] = getOutputSizeImpl(~)
        	sz1 = [1,1];
            sz2 = [1,1];
            sz3 = [1,1];
            sz4 = [1,1];
            sz5 = [1,1];
            end
        function [sz1,sz2,sz3] = getInputSizeImpl(~)
        	sz1 = [3,1];
            sz2 = [4,1];
            sz3 = [1,1];
               end
        function [cp1,cp2,cp3] = isInputComplexImpl(~)
        	cp1 = false;
            cp2 = false;
            cp3 = false;
                   end
        function [cp1,cp2,cp3,cp4,cp5] = isOutputComplexImpl(~)
        	cp1 = false;
            cp2 = false;
            cp3 = false;
            cp4 = false;
            cp5 = false;
                    end
        function [fz1,fz2,fz3] = isInputFixedSizeImpl(~)
        	fz1 = true;
            fz2 = true;
            fz3 = true;
               end
        function [fz1,fz2,fz3,fz4,fz5] = isOutputFixedSizeImpl(~)
        	fz1 = true;
            fz2 = true;
            fz3 = true;
            fz4 = true;
            fz5 = true;
        end
        function setupImpl(obj,~,~,~)
%% Implement tasks that need to be performed only once,             
import casadi.*
delta=5;%5 
N = 5; % 5 number of smaples of prediction horizon
T = delta*N; % step time
x1_0=0.7;
x2_0=0.3;
x3_0=0.5;

%% Constant Model Parameters 
L=6e-6; %[H], inductance
R0=25e-3; %internal resistance of cell
Sca1=3*3600; %[As], cell capacity
Sca2=3*3600; %[As], cell capacity
Sca3=3*3600; %[As], cell capacity
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
R_dis=R0+R_L; %Discharging path resistance, when inductor charges low SoC cell
R_ch=R_dis+Rds_on; %Charging path resistance, when higher SoC cell charges the inductor

tau_dis=L/R_dis; %[s], discharging time constant
tau_ch=L/R_ch; %[s], charging time constant

%Polynomial vector for OCV vs SoC curve
p_OCV=[88.56,-320.46,472.36,-368.96,166.57,-44.01,7.18,2.95];
%% Optimization variables and their bounds
% Optimization variables
n_states=3;
n_controls=4;
x1 = SX.sym('x1');
x2 = SX.sym('x2');
x3 = SX.sym('x3');
x = [x1;x2;x3];
u11 = SX.sym('u11');
u12 = SX.sym('u12');
u21 = SX.sym('u21');
u22 = SX.sym('u22');
u=[u11;u12;u21;u22];
weight=SX.sym('weight',4);
%other variables
D = SX.sym('D');
H_OCV = SX.sym('H_OCV');
L_OCV = SX.sym('L_OCV');
I_max_u = SX.sym('I_max_u');
tf_u = SX.sym('tf_u');
I_dis_u= SX.sym('I_dis_u');
I_s=SX.sym('I_s');

% upper and lower bounds of state and input
u_max=0.4;
u_min=td/sT;
x1_max=0.95;
x2_max=0.95;
x3_max=0.95;
x1_min=0.05;
x2_min=0.05;
x3_min=0.05;
%% Dynamic constraints
OCV1=0;OCV2=0;OCV3=0;
for i=1:8
OCV1=p_OCV(i)*x1^(8-i)+OCV1;
OCV2=p_OCV(i)*x2^(8-i)+OCV2;
OCV3=p_OCV(i)*x3^(8-i)+OCV3;
end 
charging_current = Function('charging_current',{D,H_OCV},...
{H_OCV/(sT*R_ch)*(D*sT-td)+tau_ch*(exp(-(D*sT-td)/tau_ch)-1)*H_OCV/(sT*R_ch)});

I_max=Function('I_max',{D,H_OCV},{H_OCV/R_ch*(1-exp(-((D*sT-td)/tau_ch)))});
tf=Function('tf',{D,H_OCV,L_OCV},...
 {sT*(D+tau_dis/sT*log(1+R_dis*H_OCV/((L_OCV+Vf)*R_ch)*(1-exp(-(D*sT-td)/tau_ch))))});

discharging_current=Function('discharging_current',{D,H_OCV,...
L_OCV,I_max_u,tf_u},{1/sT*(-tau_dis*I_max_u*(exp(-(tf_u-D*sT)/tau_dis)-1)-(L_OCV+Vf)/R_dis*...
(tf_u-D*sT+tau_dis*(exp(-(tf_u-D*sT)/tau_dis)-1)))});                      
             
      
Ic_u11=-charging_current(u11,OCV1); % Charging I when swtich 1 is on
Ic_u12=-charging_current(u12,OCV2); % Charging I when swtich 1 is on
Ic_u21=-charging_current(u21,OCV2); % Charging I when swtich 1 is on
Ic_u22=-charging_current(u22,OCV3); % Charging I when swtich 1 is on

I_max_u11=I_max(u11,OCV1);
I_max_u12=I_max(u12,OCV2);
I_max_u21=I_max(u21,OCV2);
I_max_u22=I_max(u22,OCV3);

tf_u11=tf(u11,OCV1,OCV2);  
tf_u12=tf(u12,OCV2,OCV1);  
tf_u21=tf(u21,OCV2,OCV3);  
tf_u22=tf(u22,OCV3,OCV2);  
                  
               
Id_u11= discharging_current(u11,OCV1,OCV2,I_max_u11,tf_u11);% Discharging current cell1-cell2 
Id_u12= discharging_current(u12,OCV2,OCV1,I_max_u12,tf_u12);% Discharging current cell2-cell1 
Id_u21= discharging_current(u21,OCV2,OCV3,I_max_u21,tf_u21);% Discharging current cell1-cell2 
Id_u22= discharging_current(u22,OCV3,OCV2,I_max_u22,tf_u22);% Discharging current cell2-cell1 


% model dynamics
I_b1=Ic_u11+Id_u12+I_s;
I_b2=Id_u11+Id_u22+Ic_u21+Ic_u12+I_s;
I_b3=Ic_u22+Id_u21+I_s;
xdot=[1/Sca1*I_b1
     1/Sca2*I_b2
     1/Sca3*I_b3];
 
 Vb1=OCV1+I_b1*R0;
 Vb2=OCV2+I_b2*R0;
 Vb3=OCV3+I_b3*R0;
 
 I_bal=[Ic_u11;Id_u12;Id_u11;Id_u22;Ic_u21;Ic_u12;Ic_u22;Id_u21];
%% Power Losses
R_ch=R_ch-R0;
R_dis=R_dis-R0;
I_ch_rms=Function('I_ch_rms',{D,H_OCV},{sqrt(abs(H_OCV^2/(sT*R_ch^2)*...
(tau_ch*exp((td-D*sT)/tau_ch)*(4-exp((td-D*sT)/tau_ch))/2+D*sT-td-(3*tau_ch/2))))});
I_ch_rms_u11=I_ch_rms(u11,OCV1);
I_ch_rms_u12=I_ch_rms(u12,OCV2);
I_ch_rms_u21=I_ch_rms(u21,OCV2);
I_ch_rms_u22=I_ch_rms(u22,OCV3);


I_d_rms=Function('I_d_rms',...
      {D,L_OCV,I_max_u,tf_u},{sqrt(abs(1/sT*(exp(-(tf_u-D*sT)/tau_dis)...
           *(2*I_max_u*( (L_OCV+Vf)/R_dis)*tau_dis+2*...
           ((L_OCV+Vf)/R_dis)^2*tau_dis)-exp(-2*(tf_u-D*sT)/tau_dis)*...
           (tau_dis*I_max_u^2/2+((L_OCV+Vf)/R_dis)^2*tau_dis/2+I_max_u*...
           ((L_OCV+Vf)/R_dis)*tau_dis)-3/2*((L_OCV+Vf)/R_dis)^2*...
           tau_dis-I_max_u*((L_OCV+Vf)/R_dis)*tau_dis+tau_dis*I_max_u^2/2+...
           ((L_OCV+Vf)/R_dis)^2*(tf_u-D*sT) )))});
       
I_d_rms_u11=I_d_rms(u11,OCV2,I_max_u11,tf_u11);
I_d_rms_u12=I_d_rms(u12,OCV1,I_max_u12,tf_u12);
I_d_rms_u21=I_d_rms(u21,OCV3,I_max_u21,tf_u21);
I_d_rms_u22=I_d_rms(u22,OCV2,I_max_u22,tf_u22);


D3=Function('D3',{D,tf_u},{(tf_u-D*sT-2*td)/sT});

D3_u11=D3(u11,tf_u11);
D3_u12=D3(u12,tf_u12);
D3_u21=D3(u21,tf_u21);
D3_u22=D3(u22,tf_u22);

P_cond=(I_ch_rms_u11^2*R_ch)*u11+(I_d_rms_u11^2*R_dis)*(D3_u11)...
      +(I_ch_rms_u12^2*R_ch)*u12+(I_d_rms_u12^2*R_dis)*(D3_u12)...
      +(I_ch_rms_u21^2*R_ch)*u21+(I_d_rms_u21^2*R_dis)*(D3_u21)...
      +(I_ch_rms_u22^2*R_ch)*u22+(I_d_rms_u22^2*R_dis)*(D3_u22)...
      + I_b1^2*R0+I_b2^2*R0+I_b3^2*R0;
    
   
P_sw=Function('P_sw',{H_OCV,I_dis_u},{0.5/sT*H_OCV*I_dis_u*tfall});

T_P_sw=P_sw(OCV1,Id_u11)+P_sw(OCV2,Id_u12)...
      +P_sw(OCV2,Id_u21)+P_sw(OCV3,Id_u22);

P_R=Function('P_R',{L_OCV},{(0.5*trr/sT)*sqrt(((L_OCV+Vf)/L)^2*trr^2)});

T_P_R=P_R(OCV2)+P_R(OCV1)+P_R(OCV3)+P_R(OCV2);

P_td=Function('P_td',{I_dis_u},{0.5/sT*Vf*I_dis_u*td});
T_P_td=P_td(Id_u11)+P_td(Id_u12)+P_td(Id_u21)+P_td(Id_u22);

PLoss=P_cond+T_P_sw+T_P_R+T_P_td;
%% Cost function
U1=[(u11-td/sT);(u21-td/sT)];
U2=[(u12-td/sT);(u22-td/sT)];
f_u=U1'*U2;
f_x=(1/3)*(x1+x2+x3); %average SoC
f_Vb=(1/3)*(Vb1+Vb2+Vb3); 
max_x=(1/100)*log(exp(100*x1)+exp(100*x2)+exp(100*x3));
min_x=-(1/100)*log(exp(-100*x1)+exp(-100*x2)+exp(-100*x3));

% Simple costs
L1=-min_x^2;
L2=(max_x-min_x)^2;
L3=(x1-f_x)^2+(x2-f_x)^2+(x3-f_x)^2;
Lc=weight(1)*L1+weight(2)*L2+weight(3)*L3+weight(4)*PLoss+f_u^2;
%% Continuous time dynamics
% Formulate discrete time dynamics
% Fixed step Runge-Kutta 4 integrator
%M = 4; % RK4 steps per interval
M = 1; % Euler steps per interval
DT = T/N/M;
% f = Function('f', {x, u}, {xdot, Lc});
f = Function('f', {x, u}, {xdot, Lc},struct('allow_free', true));
X0 = SX.sym('X0', n_states);
U = SX.sym('U',n_controls);
X = X0;
Q = 0;
%for j=1:M
    [k1, k1_q] = f(X, U);
%     [k2, k2_q] = f(X + DT/2 * k1, U);
%     [k3, k3_q] = f(X + DT/2 * k2, U);
%     [k4, k4_q] = f(X + DT * k3, U);
%     X=X+DT/6*(k1 +2*k2 +2*k3 +k4);
%    Q = Q + DT/6*(k1_q + 2*k2_q + 2*k3_q + k4_q);
     X=X+DT*k1;
     Q = Q + DT*k1_q;
%end
% F = Function('F', {X0, U}, {X, Q}, {'x0','p'}, {'xf', 'qf'});
F = Function('F', {X0, U}, {X, Q}, {'x0','p'}, {'xf', 'qf'},struct('allow_free', true));
% Start with an empty NLP
w={};
w0 = [];
lbw = [];
ubw = [];
J = 0;
g={};
lbg = [];
ubg = [];

% "Lift" initial conditions
X0 = SX.sym('X0', n_states);
w = {w{:}, X0};
lbw = [lbw; x1_min;x2_min;x3_min];
ubw = [ubw; x1_max;x2_max;x3_max];
w0 = [w0;x1_0;x2_0;x3_0];

% Formulate the NLP
Xk = X0;
for k=0:N-1
% New NLP variable for the control
Uk = SX.sym(['U_' num2str(k)], n_controls);
w = {w{:}, Uk};
lbw = [lbw; u_min;u_min;u_min;u_min];
ubw = [ubw; u_max;u_max;u_max;u_max];
w0 = [w0;  u_max;u_max;u_max;u_max];

% Integrate till the end of the interval
Fk = F('x0', Xk, 'p', Uk);
Xk_end = Fk.xf;
%J=J+Fk.qf;
J=J+Fk.qf;
% New NLP variable for state at end of interval
Xk = SX.sym(['X_' num2str(k+1)], n_states);
w = {w{:}, Xk};
lbw = [lbw; x1_min;x2_min;x3_min];
ubw = [ubw;  x1_max;x2_max;x3_max];
w0 = [w0;x1_0;x2_0;x3_0];
% Add equality constraint
g = {g{:}, Xk_end-Xk};
lbg = [lbg; 0; 0;0];
ubg = [ubg; 0;0;0];
% g = {g{:}, Xk_end-Xk,(Uk(1)-td/sT)*(Uk(2)-td/sT)};
% lbg = [lbg; 0; 0;0];
% ubg = [ubg; 0;0;0];
end
% %% Terminal cost
% J=J+w_T*(Xk_end(1)-Xk_end(2))^2;
%%
% Create an NLP solver 1e-2 :868
prob = struct('f', J, 'x', vertcat(w{:}), 'g', vertcat(g{:}),'p',[I_s;weight]);
options = struct('ipopt',struct('print_level',0,'tol', 1e-2),'print_time',false);
solver = nlpsol('solver', 'ipopt', prob, options);


obj.casadi_solver = solver;
obj.x0 = w0;
obj.lbx = lbw;
obj.ubx = ubw;
obj.lbg = lbg;
obj.ubg = ubg;
end

function [u11,u12,u21,u22,costFunc] = stepImpl(obj,x,WEIGHTS,I_source)
            w0 = obj.x0;
            lbw = obj.lbx;
            ubw = obj.ubx;
            solver = obj.casadi_solver;
            lbw(1:3) = x;
            ubw(1:3) = x;
            sol = solver('x0', w0, 'lbx', lbw, 'ubx', ubw,...
                        'lbg', obj.lbg, 'ubg', obj.ubg,'p',[I_source;WEIGHTS]);
            u11 = full(sol.x(4));
            u12 = full(sol.x(5));
            u21 = full(sol.x(6));
            u22 = full(sol.x(7));            
            costFunc = full(sol.f);           %toc
end


        function resetImpl(obj)
            % Initialize discrete-state properties.
        end
    end
end

