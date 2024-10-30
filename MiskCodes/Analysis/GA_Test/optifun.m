function J=optifun(K_pid)
%%
k=1;b=1;m=1; %system parameters
kp=K_pid(1);ki=K_pid(2);kd=(3);p=K_pid(4); %PID controller parameters

s=tf('s');
G=(1/m)/(s^2+(b/m)*s+k/m);    %plant transfer function
K = kp + ki/s + kd*s/(p*s+1); %PID controller transfer function
MR=2/(s^2+2*s+2);             %Reference model

T=G*K/(1+G*K);                %closed loof T/F: r--> y
KS=K/(1+G*K);                 %closed loop T/F: r--> u  

dt=0.01;                      %step size for time
t=0:dt:10;                    %time vector
u=heaviside(t);               %step function

ycl=lsim(T,u,t);              %output of the closed loop system 
yr=lsim(MR,u,t);              %output of the reference model
u_pid=lsim(KS,u,t);           %control input
e=u'-ycl;                     %error signal given to PID
%% cost functions
% J=norm(u_pid,1)+norm(e,1);%gives best result when used for tracking step ref
%  rho=20;
%  J=rho*sum(e.^2)+sum(u_pid.^2);
Q=1;
R=0.001;
 J = dt*sum(Q*e.^2 + R*u_pid.^2);
%J=sum(abs(e))*dt;
%J=norm(e,1);
%%
figure(1);
subplot(2,1,1)
plot(t,ycl,t,u);
legend('ycl','r','Orientation', 'Horizontal','Location','Best');
subplot(2,1,2)
plot(t,u_pid);

drawnow
